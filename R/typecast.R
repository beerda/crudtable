#' Create a custom typecast object
#'
#' This function creates a typecast object, i.e. an object that provides functions for conversion
#' from and to the internal data storage format. It is used by \code{\link{sqlDao}} to transparently
#' convert between the internal and output data format.
#'
#' @param fromInternal a function for conversion of data from the internal to the output data format
#' @param toInternal a function for conversion of data from the output to the internal data format
#' @return An object of class \code{'typecast'}, which is a list of two single-argument functions.
#' @seealso \code{\link{sqlDao}}, \code{\link{typecastDateToCharacter}},
#'   \code{\link{typecastDateToNumeric}}
#' @export
#' @examples
#' # Create a typecast object for data stored internally as character, but output as numeric values
#' tc <- typecast(as.numeric, as.character)
typecast <- function(fromInternal, toInternal) {
    structure(list(fromInternal = fromInternal,
                   toInternal = toInternal),
              class='typecast')
}
