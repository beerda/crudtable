#' @export
sqlDao <- function(con, table, attributes) {
    assert_that(is.character(table) && is.scalar(table))
    assert_that(is.character(attributes))

    attrlist <- paste0(attributes, collapse = ', ')

    dataQuery <- paste0('SELECT rowid as id, ', attrlist, ' FROM ', table)
    recordQuery <- paste0('SELECT rowid as id, ', attrlist, ' FROM ', table, ' WHERE rowid = ?')
    insertQuery <- paste0('INSERT INTO ', table, ' (', attrlist, ') ',
                          'VALUES ($', paste0(seq_along(attributes), collapse = ', $'), ')')
    updateQuery <- paste0('UPDATE ', table, ' SET ',
                          paste0(attributes, '=$', seq_along(attributes), collapse = ', '),
                          ' WHERE rowid = $', length(attributes) + 1)
    deleteQuery <- paste0('DELETE FROM ', table, ' WHERE rowid = ?')

    structure(list(
        getAttributes = function() {
            attributes
        },

        getData = function() {
            res <- DBI::dbSendQuery(con, dataQuery)
            d <- DBI::dbFetch(res)
            DBI::dbClearResult(res)
            d
        },

        getRecord = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            res <- DBI::dbSendQuery(con, recordQuery, params = list(id))
            d <- DBI::dbFetch(res)
            DBI::dbClearResult(res)
            if (nrow(d) <= 0) {
                return(NULL);
            }
            as.list(d)
        },

        insert = function(record) {
            assert_that(is.list(record))
            assert_that(length(setdiff(attributes, names(record))) == 0)
            v <- unname(record[attributes])
            DBI::dbExecute(con, insertQuery, params = v)
        },

        update = function(id, record) {
            assert_that(is.scalar(id) && is.numeric(id))
            assert_that(is.list(record))
            assert_that(length(setdiff(attributes, names(record))) == 0)
            v <- unname(record[attributes])
            DBI::dbExecute(con, updateQuery, params = c(v, id))
        },

        delete = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            DBI::dbExecute(con, deleteQuery, params = list(id))
        }
    ), class = 'dao')
}
