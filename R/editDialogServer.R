#' Server part of the edit dialog module for the create and update operations of
#' the \code{\link{crudTable}}
#'
#' The result of the call is a function that handles the edit dialog on the server part of the
#' shiny application. Its purpose is to be passed as the 'formServer' argument of the
#' \code{\link{crudTable}} module. It handles the load and storing of record values that
#' are persisted via the \code{\link{crudTable}}'s DAO.
#'
#' @param attributes A character vector of attribute names that correspond to IDs of shiny
#'     inputs (as created in the \code{\link{editDialogUI}}) and as expected by the underlying
#'     DAO.
#' @param validators A list of validators that validate the user input and show an error message
#'     (see \code{\link{validator}}).
#' @return A function that is used by shiny to handle the inputs of the edit dialog. The
#'     returned function expects three arguments: \code{input}, \code{output} and \code{session}.
#'     It returns a list of three reactive values:
#'     \itemize{
#'         \item \code{saveTrigger}, which triggers by this function on submit of the edit dialog,
#'              after the dialog data are stored into the \code{record} reactive value;
#'         \item \code{loadTrigger}, which expects to be triggerred by \code{\link{crudTable}}
#'              after the form data are prepared in the \code{record} reactive value
#'              in order to load them into the form;
#'         \item \code{record} the list of data values to be passed to/from the form.
#'     }
#' @seealso editDialogUI, crudTable, validator
#' @export
editDialogServer <- function(attributes,
                             validators = list()) {
    assert_that(is.character(attributes))
    assert_that(is.validator(validators))

    function(input, output, session) {
        result <- list(saveTrigger = reactiveVal(0),
                       loadTrigger = reactiveVal(0),
                       record = reactiveVal(NULL))

        observeEvent(result$loadTrigger(), ignoreInit = TRUE, {
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
            result$saveTrigger(result$saveTrigger() + 1)
            removeModal()
        })

        result
    }
}
