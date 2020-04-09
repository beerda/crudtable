con <- dbConnect(RSQLite::SQLite(), ":memory:")

shiny::onStop(function() {
    dbDisconnect(con)
})

dbWriteTable(con, 'CO2', as.data.frame(CO2))


dao <- list(
    getData=function() {
        res <- dbSendQuery(con, 'SELECT rowid as id, * FROM CO2')
        d <- dbFetch(res)
        dbClearResult(res)
        d
    },

    getRecord=function(id) {
        res <- dbSendQuery(con, 'SELECT rowid as id, * FROM CO2 WHERE rowid = ?',
                           params=list(id))
        d <- dbFetch(res)
        dbClearResult(res)
        as.list(d)
    },

    insert=function(record) {
        cat('Inserting:\n')
        str(record)
        n <- names(record)
        v <- unname(record)
        dbExecute(con, paste0('INSERT INTO CO2 (', paste0(n, collapse=', '),
                              ') VALUES ($', paste0(seq_along(v), collapse=', $'), ')'),
                  params=v)
    },

    update=function(id, record) {
        cat('Updating ', id, ':\n')
        str(record)
        n <- names(record)
        v <- unname(record)
        dbExecute(con, paste0('UPDATE CO2 SET ', paste0(n, '=$', seq_along(v), collapse=', '),
                              'WHERE rowid=$', length(v) + 1),
                  params=c(v, id))
    },

    delete=function(id) {
        cat('Deleting ', id, '\n')
        dbExecute(con, 'DELETE FROM CO2 WHERE rowid=?',
                  params=list(id))
    }
)
