#' Create a typecast object that converts between the output \code{\link{Date}} and internal
#' \code{character} data type
#'
#' @param format the format of the character representation of the date (see \code{\link{strptime}}
#'   for more information)
#' @return An instance of the \code{'typecast'} class
#' @seealso \code{\link{typecast}}, \code{\link{typecastDateToNumeric}}
#' @export
typecastDateToCharacter <- function(format = '%Y-%m-%d') {
    typecast(fromInternal = function(x) as.Date(x, format = format),
             toInternal = function(x) as.character(x, format = format))
}
