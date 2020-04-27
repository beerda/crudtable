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
#' @return A function that is used by shiny to handle the inputs of the edit dialog.
#' @export
editDialogServer <- function(attributes,
                             validators = list()) {
    assert_that(is.character(attributes))

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

        errors <- rep(FALSE, length(validators))
        names(errors) <- names(validators)
        errors <- reactiveVal(errors)
        for (n in names(validators)) {
            local({
                nn <- n
                observeEvent(input[[nn]], {
                    v <- input[[nn]]
                    err <- errors()
                    errMsg <- validators[[nn]][['errorMessage']]
                    invalid <- !validators[[nn]][['f']](v)
                    if (!is.logical(invalid) || is.null(invalid) || is.na(invalid)) {
                        warning('Ignoring "', nn, '" validator\'s non-logical result: ', invalid)
                        invalid <- FALSE
                    }
                    shinyFeedback::feedbackDanger(session$ns(nn), invalid, errMsg)
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
