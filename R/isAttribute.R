#' @export
is.attribute <- function(m) {
    is.list(m) &&
        inherits(m, 'attribute')
}
