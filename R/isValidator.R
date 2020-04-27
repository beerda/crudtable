#' @export
is.validator <- function(v) {
    is.list(v) &&
        all(sapply(v, function(vv) {
            inherits(vv, 'validator') &&
                is_scalar_character(vv$errorMessage) &&
                is.function(vv$f)
        }))
}
