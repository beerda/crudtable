#' Defines a validation function and an error message for an edit dialog form input
#'
#' Validators are typically passed to the \code{\link{editDialogServer}} function that
#' creates a server-part handler of the edit dialog.
#'
#' @param inputIds a vector of input IDs for the validation function \code{f} to be bound on
#' @param errorMessages a vector of error messages corresponding to the input IDs. This character
#'     vector is recycled as needed to match the length of \code{inputIds}
#' @param f a validation function that expects a single input argument and returns \code{TRUE} if
#'     the given input is valid. Note that this function must handle correctly the \code{NULL}
#'     value as well as the \code{NA} value.
#' @return A list of instances of the S3 class \code{validator}. The size of the resulting list
#'     equals to the number of input IDs in 'inputIds'.
#' @seealso filledValidator, editDialogServer
#' @examples
#' \dontrun{
#'     # create a handler that ensures that attr1 is an odd number and that 'attr2' and 'attr3'
#'     # are filled. (Note that instead of enumerating the attribute names, a DAO function
#'     # "getAttributes()" may be called.)
#'     handler <- editDialogServer(
#'         attributes = c('attr1', 'attr2', 'attr3')
#'         validators = c(
#'             validator('attr1',
#'                       'attr1 must be odd',
#'                       function(v) { !is.null(v) && !is.na(v) && v %% 2 != 0 }),
#'             filledValidator(c('attr2', 'attr3'))
#'         )
#'    )
#' }
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
