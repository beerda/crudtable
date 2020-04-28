#' Checks if the inputs are not empty.
#'
#' This validator tests if the inputs given by 'inputIds' are not empty, i.e., non-null,
#' non-NA and different from an empty string.
#'
#' @param inputIds IDs of shiny inputs that are to be tested for emptiness
#' @param errorMessages a vector of error messages corresponding to the input IDs. This character
#'     vector is recycled as needed to match the length of \code{inputIds}
#' @return A list of instances of the S3 class \code{validator}. The size of the resulting list
#'     equals to the number of input IDs in 'inputIds'.
#' @seealso validator
#' @export
filledValidator <- function(inputIds, errorMessages = 'Must not be empty.') {
    validator(inputIds,
              errorMessages,
              function(v) {
                  !is.null(v) && all(!is.na(v)) && all(trimws(v) != '')
              })
}
