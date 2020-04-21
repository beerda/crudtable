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
