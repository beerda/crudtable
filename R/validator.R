#' @export
validator <- function(inputIds, errorMessages, f) {
    assert_that(is.character(inputIds))
    assert_that(is.character(errorMessages))
    assert_that(length(inputIds) >= length(errorMessages))
    assert_that(is.function(f))

    errorMessages <- rep_len(errorMessages, length(inputIds))
    res <- map(errorMessages, function(m) {
        structure(list(errorMessage = m, f = f),
                  class = 'validator')
    })
    names(res) <- inputIds
    res
}


#' @export
is.validator <- function(v) {
    is.list(v) &&
        all(sapply(v, function(vv) {
            inherits(vv, 'validator') &&
                is_scalar_character(vv$errorMessage) &&
                is.function(vv$f)
        }))
}


#' @export
filledValidator <- function(inputIds, errorMessages = 'Must not be empty.') {
    validator(inputIds,
              errorMessages,
              function(v) {
                  !is.null(v) && all(!is.na(v)) && all(trimws(v) != '')
              })
}
