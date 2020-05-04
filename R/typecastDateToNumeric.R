#' @export
typecastDateToNumeric <- function() {
    typecast(fromInternal = function(x) as.Date(x, origin = '1970-01-01'),
             toInternal = as.numeric)
}
