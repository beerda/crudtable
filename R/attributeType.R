#' Provide a rich description of the variable's data type
#'
#' Function is used in DAO objects within the \code{getAttributes} method - see e.g.
#' \code{\link{sqlDao}}.
#'
#' @param x A value of which the type has to be determined
#' @return A list of detailed description of \code{x}'s data type. The list always contains the
#'   \code{type} element, which contains:
#'   \itemize{
#'     \item \code{mode(x)} if \code{x} is an atomic data value (such as character, numeric etc.);
#'     \item \code{class(x)} if \code{x} is an S3 object.
#'   }
#'   Additionally, the returned list may contain other elements such as \code{levels} for factors.
#' @export
attributeType <- function(x) {
    res <- list()

    if (is.object(x)) {
        res$type <- class(x)
        if (is.factor(x)) {
            res$levels <- levels(x)
        }

    } else {
        res$type <- mode(x)
    }

    res
}
