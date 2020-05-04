#' @export
typecast <- function(fromInternal, toInternal) {
    structure(list(fromInternal = fromInternal,
                   toInternal = toInternal),
              class='typecast')
}
