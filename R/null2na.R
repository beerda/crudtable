#' @export
null2na <- function(x) {
    ifelse(is.null(x), NA, x)
}
