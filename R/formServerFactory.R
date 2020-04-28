#' A factory that creates a server-side function that handles the \code{\link{formUI}}.
#'
#' This factory creates a function that handles the server-side functionality of the
#' \code{\link{formUI}}. It is responsible for loading data into the form for editing, collecting
#' the data after submitting them by the user and validating the user input.
#'
#' The purpose of the created function is to be passed as the 'formServer' argument for the
#' \code{\link{crudTable}} module.
#'
#' @param dao A data access object (DAO), see \code{\link{dao}}, whose attributes are to be obtained
#'   from the form and provide to the \code{\link{crudtable}}.
#' @param validators A list of validators that validate the user input and show an error message,
#'   see \code{\link{validator}}.
#' @return A function that is used by shiny to handle the inputs of the form. The returned function
#'   expects three arguments: \code{input}, \code{output} and \code{session}. It returns a list of
#'   three reactive values: \itemize{ \item \code{saveTrigger}, which triggers by this function on
#'   submit of the form, after the data are stored into the \code{record} reactive value; \item
#'   \code{loadTrigger}, which expects to be triggerred by \code{\link{crudTable}} after the form
#'   data are prepared in the \code{record} reactive value in order to load them into the form;
#'   \item \code{record} the list of data values to be passed to/from the form. }
#' @seealso formUI, crudTable, validator
#' @export
formServerFactory <- function(dao,
                              validators = list()) {
    assert_that(is.dao(dao))
    assert_that(is.validator(validators))

    attributes <- dao$getAttributes()

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
