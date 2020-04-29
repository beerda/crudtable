#' Test whether the given object is a correct \code{dao} class
#' @param x An object to be tested
#' @return \code{TRUE} if \code{x} is a valid DAO object.
#' @seealso \code{\link{dataFrameDao}}, \code{\link{sqlDao}}
#' @export
is.dao <- function(x) {
    is.list(x) &&
        inherits(x, 'dao') &&
        is.function(x$getAttributes) &&
        is.function(x$getData) &&
        is.function(x$getRecord) &&
        is.function(x$insert) &&
        is.function(x$update) &&
        is.function(x$delete)
}
