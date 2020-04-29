#' Checks whether the given argument is a valid variable object
#'
#' This function tests if \code{v} is a list of objects that are instances of the S3 class
#' \code{\link{validator}} and whether each instance contains an 'errorMessage' character
#' scalar and a function 'f' as an element.
#'
#' @param v An object to be tested
#' @return \code{TRUE} if 'v' is a valid \code{\link{validator}}
#' @seealso \code{\link{validator}}, \code{\link{filledValidator}}
#' @export
is.validator <- function(v) {
    is.list(v) &&
        all(sapply(v, function(vv) {
            inherits(vv, 'validator') &&
                is_scalar_character(vv$errorMessage) &&
                is.function(vv$f)
        }))
}
