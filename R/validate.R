#' @export
validate <- function(inputIds, errorMessages, f) {
    assert_that(is.character(inputIds))
    assert_that(is.character(errorMessages))
    assert_that(length(inputIds) >= length(errorMessages))
    assert_that(is.function(f))

    errorMessages <- rep_len(errorMessages, length(inputIds))
    res <- map(errorMessages, function(m) {
        list(errorMessage = m, f = f)
    })
    names(res) <- inputIds
    res
}

#' @export
validateNotNA <- function(inputIds, errorMessages = 'Must not be empty.') {
    validate(inputIds,
             errorMessages,
             function(v) {
                 !is.null(v) && all(!is.na(v)) && all(trimws(v) != '')
             })
}
