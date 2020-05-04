#' Test if the argument is a valid typecast object
#'
#' @param x An object to be tested
#' @return \code{TRUE} if \code{x} is a valid instance of the \code{typecast} class.
#' @seealso \code{\link{typecast}}
#' @export
is.typecast <- function(x) {
    inherits(x, 'typecast') &&
        is.list(x) &&
        length(x) == 2 &&
        all(names(x) == c('fromInternal', 'toInternal')) &&
        is.function(x[[1]]) &&
        is.function(x[[2]])
}
