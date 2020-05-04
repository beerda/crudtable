#' @export
is.typecast <- function(x) {
    inherits(x, 'typecast') &&
        is.list(x) &&
        length(x) == 2 &&
        all(names(x) == c('fromInternal', 'toInternal')) &&
        is.function(x[[1]]) &&
        is.function(x[[2]])
}
