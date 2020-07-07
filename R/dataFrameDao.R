#' A Data Access Object (DAO) that stores the data in the internal data frame.
#'
#' DAO is a list that provides basic backend CRUD functionality to the \code{\link{crudTable}}.
#' This DAO stores internally the data into a data frame, that is, the data are NOT stored on the
#' disk in any way.
#'
#' @section Generally about DAO objects:
#' Generally, all DAO objects have to provide the following functions:
#' \itemize{
#'     \item \code{getAttributes()} -- get the list of attribute definitions. Names of the list
#'         correspond to names of attributes. Each element of that list contains a list with
#'         character element \code{'type'} that specifies the data type (\code{factor},
#'         \code{character}, \code{numeric}, \code{logical}). Factors have also a character vector
#'         \code{levels} with level names;
#'     \item \code{getData()} -- get the data frame with all data. The data frame contain all
#'         columns as indicated in
#'         the \code{getAttributes()} function plus the \code{"id"} column with numeric row
#'         identifier;
#'     \item \code{getRecord(id)} -- get the record of given ID, as a list;
#'     \item \code{insert(record)} -- store the new record, the ID attribute of the record must not
#'         be set, it is determined automatically by the DAO object;
#'     \item \code{update(id, record)} -- update the stored record of given ID by data given in the
#'         list \code{record};
#'     \item \code{delete(id)} -- delete the record of given ID.
#' }
#'
#' @param d A data frame to create DAO object for
#' @return An S3 object of class \code{dao}, which is a list having as elements the functions
#'     described above
#' @seealso \code{\link{sqlDao}}, \code{\link{is.dao}}
#' @export
#' @aliases dao
#' @examples
#' d <- CO2[1:5, ]
#' dao <- dataFrameDao(d)
#' str(dao$getAttributes())
#' print(dao$getData())
#' dao$insert(list(Plant='Qn1', Type='Quebec', Treatment='chilled', conc=1000, uptake=2000))
#' dao$delete(1)
#' print(dao$getData)
dataFrameDao <- function(d, reactive = TRUE) {
    assert_that(is.data.frame(d))
    assert_that(all(colnames(d) != 'id'))

    d <- as.data.frame(d, stringsAsFactors = FALSE)
    data <- cbind(id=seq_len(nrow(d)), d)
    attributes <- map(d, attributeType)

    if (reactive) {
        dataChangedTrigger <- reactiveVal(0, label=paste0(table, ' trigger'))
    } else {
        dataChangedTrigger <- function(...) { }
    }

    structure(list(
        observeDataChange = function() {
            dataChangedTrigger()
        },

        getAttributes = function() {
            attributes
        },

        getData = function() {
            dataChangedTrigger()
            data
        },

        getRecord = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            dataChangedTrigger()
            as.list(data[data$id == id, ])
        },

        insert = function(record) {
            assert_that(is.list(record))
            assert_that(length(setdiff(names(attributes), names(record))) == 0)
            record$id <- max(0, data$id) + 1
            record <- as.data.frame(record, stringsAsFactors = FALSE)
            data <<- rbind(data, record[colnames(data)])
            dataChangedTrigger(dataChangedTrigger() + 1)
            invisible(1)
        },

        update = function(id, record) {
            assert_that(is.scalar(id) && is.numeric(id))
            assert_that(is.list(record))
            assert_that(length(setdiff(names(attributes), names(record))) == 0)
            record <- as.data.frame(record, stringsAsFactors = FALSE)
            data[data$id == id, names(attributes)] <<- record[names(attributes)]
            rownames(data) <<- NULL
            dataChangedTrigger(dataChangedTrigger() + 1)
            invisible(1)
        },

        delete = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            data <<- data[data$id != id, ]
            rownames(data) <<- NULL
            dataChangedTrigger(dataChangedTrigger() + 1)
            invisible(1)
        }
    ), class = 'dao')
}
