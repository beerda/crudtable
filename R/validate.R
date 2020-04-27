#' @export
validate <- function(inputId, errorMessage, f) {
    res <- list(list(errorMessage = errorMessage,
                     f = f))
    names(res) <- inputId
    res
}

#' @export
validateNA <- function(inputId, errorMessage = 'Must not be empty.') {
    validate(inputId,
             errorMessage,
             function(v) {
                 !is.null(v) && !is.na(v) && trimws(v) != ''
             })
}
