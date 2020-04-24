#' Server part of the edit dialog module for the create and update operations of
#' the \code{\link{crudTable}}
#'
#' The result of the call is a function that handles the edit dialog on the server part of the
#' shiny application. Its purpose is to be passed as the 'formServer' argument of the
#' \code{\link{crudTable}} module. It handles the load and storing of record values that
#' are persisted via the \code{\link{crudTable}}'s DAO.
#'
#' @param attributes A character vector of attribute names that correspond to IDs of shiny
#'     inputs (as created in the \code{\link{editDialog}}) and as expected by the underlying
#'     DAO
#' @param na A character vector of attribute names which are allowed to be empty.
#' @param naMsg An error message shown on submit of empty element that is not listed in the 'na'
#'     argument.
#' @return A function that is used by shiny to handle the inputs of the edit dialog.
#' @export
editDialogServer <- function(attributes, na=NULL, naMsg='Must not be empty.') {
    assert_that(is.character(attributes))
    if (!is.null(na)) {
        assert_that(is.character(na))
        assert_that(length(setdiff(na, attributes)) == 0)
    }

    nona <- setdiff(attributes, na)

    function(input, output, session) {
        result <- list(trigger = reactiveVal(0),
                       record = reactiveVal(NULL))

        observe({
            rec <- result$record()
            if (!is.null(rec)) {
                for (colid in attributes) {
                    # update value of the input UI
                    session$sendInputMessage(colid, list(value = rec[[colid]]))
                }
            }
        })

        errors <- rep(FALSE, length(nona))
        names(errors) <- nona
        errors <- reactiveVal(errors)
        for (n in nona) {
            local({
                nn <- n
                observeEvent(input[[nn]], {
                    v <- input[[nn]]
                    err <- errors()
                    invalid <- is.null(v) || is.na(v) || trimws(v) == ''
                    shinyFeedback::feedbackDanger(session$ns(nn), invalid, naMsg)
                    err[nn] <- invalid
                    errors(err)
                }, ignoreNULL=FALSE)
            })
        }

        observe({
            err <- errors()
            if (any(err)) {
                shinyjs::disable('submit')
            } else {
                shinyjs::enable('submit')
            }
        })

        observeEvent(input$submit, {
            record <- map(attributes, function(p) { input[[p]] })
            names(record) <- attributes
            result$record(record)
            result$trigger(result$trigger() + 1)
            removeModal()
        })

        result
    }
}
