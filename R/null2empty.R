#' @export
null2empty <- function(x) {
    ifelse(is.null(x), '', x)
}
