#' Create simple edit form UI based on data provided by DAO
#'
#' Based on attributes provided by the \code{dao} Data Access Object, a simple edit dialog is
#' constructed with each attribute corresponding to an input as follows:
#' \itemize{
#'   \item name of the UI is the same as the name of the attribute;
#'   \item factor attributes correspond to the \code{\link[shiny]{selectInput}};
#'   \item numeric attributes correspond to the \code{\link[shiny]{numericInput}};
#'   \item logical attributes correspond to the \code{\link[shiny]{checkboxInput}};
#'   \item attributes of any other type correspond to the \code{\link[shiny]{textInput}};
#' }
#'
#' @param dao a Data Access Object (see \code{\link{dataFrameDao}} or \code{\link{sqlDao}})
#' @return A function that creates the modal dialog window with inputs corresponding to
#'   \code{dao}'s attributes.
#' @seealso \code{\link{formServerFactory}}, \code{\link{crudTableServer}}, \code{\link{dataFrameDao}},
#'   \code{\link{sqlDao}}
#' @export
simpleFormUIFactory <- function(dao) {
    assert_that(is.dao(dao))

    attributes <- dao$getAttributes()

    function(id) {
        ns <- NS(id)
        widgets <- map(names(attributes), function(name) {
            a <- attributes[[name]]
            if ('factor' %in% a$type) {
                selectInput(ns(name), name, choices = a$levels)
            } else if ('numeric' %in% a$type) {
                numericInput(ns(name), name, value = NA)
            } else if ('logical' %in% a$type) {
                checkboxInput(ns(name), name)
            } else {
                textInput(ns(name), name, value = NA)
            }
        })
        do.call(formUI, c(list(id), widgets))
    }
}
