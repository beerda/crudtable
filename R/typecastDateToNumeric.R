#' Create a typecast object that converts between the output \code{\link{Date}} and internal
#' \code{numeric} data type
#'
#' @return An instance of the \code{'typecast'} class
#' @seealso \code{\link{typecast}}, \code{\link{typecastDateToCharacter}}
#' @export
typecastDateToNumeric <- function() {
    typecast(fromInternal = function(x) as.Date(x, origin = '1970-01-01'),
             toInternal = as.numeric)
}
