#' @export
#' @importFrom yaml read_yaml
#' @import DBI
sqlDao <- function(con, def) {
    if (is.character(def) && is.scalar(def)) {
        def <- read_yaml(def)
    }
    assert_that(is.list(def))

    persist <- map_lgl(def$columns, function(col) col$persistent)
    persist <-names(def$columns)
    cols <- paste0(persist, collapse=', ')

    dataQuery <- paste0('SELECT rowid as id, ', cols, ' FROM ', def$table)
    recordQuery <- paste0('SELECT rowid as id, ', cols, ' FROM ', def$table, ' WHERE rowid = ?')
    insertQuery <- paste0('INSERT INTO ', def$table, ' (', cols, ') ',
                          'VALUES ($', paste0(seq_along(persist), collapse=', $'), ')')
    updateQuery <- paste0('UPDATE ', def$table, ' SET ',
                          paste0(persist, '=$', seq_along(persist), collapse=', '),
                          ' WHERE rowid=$', length(persist) + 1)
    deleteQuery <- paste0('DELETE FROM ', def$table, ' WHERE rowid=?')

    list(
        getData=function() {
            res <- dbSendQuery(con, dataQuery)
            d <- dbFetch(res)
            dbClearResult(res)
            d
        },

        getRecord=function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            res <- dbSendQuery(con, recordQuery, params=list(id))
            d <- dbFetch(res)
            dbClearResult(res)
            if (nrow(d) <= 0) {
                return(NULL);
            }
            as.list(d)
        },

        insert=function(record) {
            assert_that(is.list(record))
            assert_that(length(setdiff(persist, names(record))) == 0)
            v <- unname(record[persist])
            dbExecute(con, insertQuery, params=v)
        },

        update=function(id, record) {
            assert_that(is.scalar(id) && is.numeric(id))
            assert_that(is.list(record))
            assert_that(length(setdiff(persist, names(record))) == 0)
            v <- unname(record[persist])
            dbExecute(con, updateQuery, params=c(v, id))
        },

        delete=function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            dbExecute(con, deleteQuery, params=list(id))
        }
    )
}