#' @export
typecastDateToCharacter <- function(format = '%Y-%m-%d') {
    typecast(fromInternal = function(x) as.Date(x, format = format),
             toInternal = function(x) as.character(x, format = format))
}
