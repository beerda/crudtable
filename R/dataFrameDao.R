#' @export
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
