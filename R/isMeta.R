#' @export
is.meta <- function(m) {
    is.list(m) &&
        inherits(m, 'meta')
}
