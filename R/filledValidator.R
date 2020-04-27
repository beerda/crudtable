#' @export
filledValidator <- function(inputIds, errorMessages = 'Must not be empty.') {
    validator(inputIds,
              errorMessages,
              function(v) {
                  !is.null(v) && all(!is.na(v)) && all(trimws(v) != '')
              })
}
