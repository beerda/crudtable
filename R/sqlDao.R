#' A Data Access Object (DAO) that uses the DBI interface to access the data.
#'
#' DAO is a list that provides basic backend CRUD functionality to the \code{\link{crudTableServer}}. This
#' DAO uses DBI to store the data. The DBI table accessed with this DAO object must not contain the
#' \code{'id'} attribute, as it is internally created from the DBI's \code{'rowid'} attribute.
#'
#' See \code{\link{dataFrameDao}} for more details on Data Access Objects.
#'
#' Since the DBI interface typically converts various complex R data types (such as \code{Date})
#' into atomic types such as number, character string and so on, \code{sqlDao} may optionally
#' convert the data for you into a more convenient format -- see the \code{typecast} argument.
#'
#' @param con A DBI connection
#' @param table A character string of the name of the table to be accessed
#' @param typecast A named list of \code{\link{typecast}} objects. If non-empty, the elements of
#'   this list must correspond to the attributes of the SQL data table. A conversion between
#'   internal and output data types is then performed on data insert, update or retrieval.
#' @return A DAO object, i.e. a list of functions for CRUD operations on the DBI table as neeeded by
#'   the \code{\link{crudTableServer}} module
#' @seealso \code{\link{dataFrameDao}}, \code{\link{is.dao}}, \code{\link{typecast}}
#' @export
#' @examples
#' library(DBI)
#' library(RSQLite)
#'
#' # Create an in-memory database
#' con <- dbConnect(RSQLite::SQLite(), ":memory:")
#'
#' # Create an empty data table
#' data <- data.frame(date = character(0), value = numeric(0))
#' dbWriteTable(con, 'mytable', data)
#'
#' # Create Data Access Object - the date attribute will be internally stored as character
#' # but transparently returned as 'Date' by the DAO
#' dao <- sqlDao(con,
#'               table = 'mytable',
#'               typecast = list(date = typecastDateToCharacter()))
#'
#' # Insert data record
#' dao$insert(list(date = Sys.Date(), value = 100))
#'
#' # Print data table
#' print(dao$getData())
#'
#' # Disconnect from the database
#' dbDisconnect(con)
sqlDao <- function(con, table, typecast = list(), meta = list()) {
    assert_that(is.character(table) && is.scalar(table))
    assert_that(is.list(typecast))
    assert_that(all(map_lgl(typecast, is.typecast)))
    assert_that(is.list(meta))
    assert_that(all(map_lgl(meta, is.meta)))

    attributes <- DBI::dbListFields(con, table)
    attrlist <- paste0(attributes, collapse = ', ')

    if (length(typecast) <= 0) {
        typecast <- .metaVec(meta, 'typecast')
    }

    assert_that(length(setdiff(names(typecast), attributes)) == 0)

    dataQuery <- paste0('SELECT rowid as id, ', attrlist, ' FROM ', table)
    recordQuery <- paste0('SELECT rowid as id, ', attrlist, ' FROM ', table, ' WHERE rowid = ?')
    insertQuery <- paste0('INSERT INTO ', table, ' (', attrlist, ') ',
                          'VALUES ($', paste0(seq_along(attributes), collapse = ', $'), ')')
    updateQuery <- paste0('UPDATE ', table, ' SET ',
                          paste0(attributes, '=$', seq_along(attributes), collapse = ', '),
                          ' WHERE rowid = $', length(attributes) + 1)
    deleteQuery <- paste0('DELETE FROM ', table, ' WHERE rowid = ?')
    infoQuery <- paste0('SELECT ', attrlist, ' FROM ', table, ' LIMIT 0')

    castme <- function(d, how) {
        walk(names(typecast), function(n) {
            d[[n]] <<- typecast[[n]][[how]](d[[n]])
        })
        d
    }

    res <- DBI::dbSendQuery(con, infoQuery)
    row <- DBI::dbFetch(res, n = 0)
    DBI::dbClearResult(res)
    row <- castme(row, 'fromInternal')
    types <- map(row, attributeType)

    structure(list(
        getAttributes = function() {
            types
        },

        getMeta = function() {
            meta
        },

        getData = function() {
            res <- DBI::dbSendQuery(con, dataQuery)
            d <- DBI::dbFetch(res)
            DBI::dbClearResult(res)
            castme(d, 'fromInternal')
        },

        getRecord = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            res <- DBI::dbSendQuery(con, recordQuery, params = list(id))
            d <- DBI::dbFetch(res)
            DBI::dbClearResult(res)
            if (nrow(d) <= 0) {
                return(NULL);
            }
            as.list(castme(d, 'fromInternal'))
        },

        insert = function(record) {
            assert_that(is.list(record))
            assert_that(length(setdiff(attributes, names(record))) == 0)
            record <- castme(record, 'toInternal')
            v <- unname(record[attributes])
            res <- DBI::dbExecute(con, insertQuery, params = v)
            res
        },

        update = function(id, record) {
            assert_that(is.scalar(id) && is.numeric(id))
            assert_that(is.list(record))
            assert_that(length(setdiff(attributes, names(record))) == 0)
            record <- castme(record, 'toInternal')
            v <- unname(record[attributes])
            res <- DBI::dbExecute(con, updateQuery, params = c(v, id))
            res
        },

        delete = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            res <- DBI::dbExecute(con, deleteQuery, params = list(id))
            res
        }
    ), class = 'dao')
}
