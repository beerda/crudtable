#' A Data Access Object (DAO) that stores the data in the internal data frame.
#'
#' DAO is a list that provides basic backend CRUD functionality to the \code{\link{crudTable}}. This DAO stores
#' internally the data into a data frame, that is, the data are NOT stored on the disk in any way.
#'
#' @section Generally about DAO objects:
#' Generally, all DAO objects have to provide the following functions:
#' \itemize{
#'     \item \code{getAttributes()} -- get the character vector of attribute (column) names;
#'     \item \code{getData()} -- get the data frame with all data. The data frame contain all columns as indicated in
#'        the \code{getAttributes()} function plus the \code{"id"} column with numeric row identifier;
#'     \item \code{getRecord(id)} -- get the record of given ID, as a list;
#'     \item \code{insert(record)} -- store the new record, the ID attribute of the record must not be set, it is
#'        determined automatically by the DAO object;
#'     \item \code{update(id, record)} -- update the stored record of given ID by data given in the list \code{record};
#'     \item \code{delete(id)} -- delete the record of given ID.
#' }
#'
#' @param d A data frame to create DAO object for
#' @return An S3 object of class \code{dao}, which is a list having as elements the functions
#'     described above
#' @seealso sqlDao
#' @export
#' @examples
#' d <- CO2[1:5, ]
#' dao <- dataFrameDao(d)
#' print(dao$getAttributes())
#' print(dao$getData())
#' dao$insert(list(Plant='Qn1', Type='Quebec', Treatment='chilled', conc=1000, uptake=2000))
#' dao$delete(1)
#' print(dao$getData)
dataFrameDao <- function(d) {
    assert_that(is.data.frame(d))
    assert_that(all(colnames(d) != 'id'))

    attributes <- colnames(d)
    data <- cbind(id=seq_len(nrow(d)), d)

    structure(list(
        getAttributes = function() {
            attributes
        },

        getData = function() {
            data
        },

        getRecord = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            as.list(data[data$id == id, ])
        },

        insert = function(record) {
            assert_that(is.list(record))
            assert_that(length(setdiff(attributes, names(record))) == 0)
            record$id <- max(data$id) + 1
            data <<- rbind(data, record[colnames(data)])
            invisible(1)
        },

        update = function(id, record) {
            assert_that(is.scalar(id) && is.numeric(id))
            assert_that(is.list(record))
            assert_that(length(setdiff(attributes, names(record))) == 0)
            data[data$id == id, attributes] <<- record[attributes]
            rownames(data) <<- NULL
            invisible(1)
        },

        delete = function(id) {
            assert_that(is.scalar(id) && is.numeric(id))
            data <<- data[data$id != id, ]
            rownames(data) <<- NULL
            invisible(1)
        }
    ), class = 'dao')
}
