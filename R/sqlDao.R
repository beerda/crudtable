#' A Data Access Object (DAO) that uses the DBI interface to access the data.
#'
#' DAO is a list that provides basic backend CRUD functionality to the \code{\link{crudTable}}.
#' This DAO uses DBI to store the data. The DBI table accessed with this DAO object must not
#' contain the 'id' attribute, as it is internally created from the DBI's 'rowid' attribute.
#'
#' See \code{\link{dataFrameDao}} for more details on Data Access Objects.
#'
#' @param con A DBI connection
#' @param table A character string of the name of the table to be accessed
#' @param attributes A character string of attribute names to be handled by this DAO.
#' @return A DAO object, i.e. a list of functions for CRUD operations on the DBI table as
#'     neeeded by the \code{\link{crudTable}} module
#' @export
#' @examples
#' \dontrun{
#' library(DBI)
#' library(RSQLite)
#'
#' # Create an in-memory database
#' con <- dbConnect(RSQLite::SQLite(), ":memory:")
#'
#' # Create CO2 data table from the CO2 data frame
#' dbWriteTable(con, 'CO2', as.data.frame(CO2[1:5, ]))
#'
#' # Create Data Access Object
#' dao <- sqlDao(con,
#'               table = 'CO2')
#' }
sqlDao <- function(con, table) {
    assert_that(is.character(table) && is.scalar(table))

    attributes <- DBI::dbListFields(con, table)
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
