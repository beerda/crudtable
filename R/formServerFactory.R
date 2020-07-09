#' A factory that creates a server-side function that handles the \code{\link{formUI}}.
#'
#' This factory creates a function that handles the server-side functionality of the
#' \code{\link{formUI}}. It is responsible for loading data into the form for editing, collecting
#' the data after submitting them by the user and validating the user input.
#'
#' The purpose of the created function is to be passed as the 'formServer' argument for the
#' \code{\link{crudTableServer}} module.
#'
#' @param dao A data access object (DAO), see \code{\link{dao}}, whose attributes are to be obtained
#'   from the form and provide to the \code{\link{crudTableServer}}.
#' @param validators A list of validators that validate the user input and show an error message,
#'   see \code{\link{validator}}.
#' @return A function that is used by shiny to handle the inputs of the form. The returned function
#'   expects three arguments: \code{input}, \code{output} and \code{session}. It returns a list of
#'   three reactive values: \itemize{ \item \code{saveTrigger}, which triggers by this function on
#'   submit of the form, after the data are stored into the \code{record} reactive value; \item
#'   \code{loadTrigger}, which expects to be triggerred by \code{\link{crudTableServer}} after the form
#'   data are prepared in the \code{record} reactive value in order to load them into the form;
#'   \item \code{record} the list of data values to be passed to/from the form. }
#' @seealso \code{\link{formUI}}, \code{\link{crudTableServer}}, \code{\link{validator}}
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
                for (colid in names(attributes)) {
                    # update value of the input UI
                    session$sendInputMessage(colid, list(value = rec[[colid]]))
                }
            }
        })

        errors <- map(names(validators), function(n) { reactiveVal(FALSE) })
        names(errors) <- names(validators)
        for (n in names(validators)) {
            local({
                nn <- n
                # ignoreInit = TRUE was set to speed-up the execution on shinyapps.io.
                # Hopefully, it will not break anything else.
                observeEvent(input[[nn]], ignoreNULL = FALSE, ignoreInit = TRUE, {
                    v <- input[[nn]]
                    errMsg <- validators[[nn]][['errorMessage']]
                    invalid <- !validators[[nn]][['f']](v)
                    if (!is.logical(invalid) || is.null(invalid) || is.na(invalid)) {
                        warning('Ignoring "', nn, '" validator\'s non-logical result: ', invalid)
                        invalid <- FALSE
                    }
                    if (invalid) {
                        shinyFeedback::showFeedbackDanger(nn, errMsg)
                    } else {
                        shinyFeedback::hideFeedback(nn)
                    }
                    errors[[nn]](invalid)
                })
            })
        }

        observe({
            err <- map(errors, function(e) { e() })
            if (any(unlist(err))) {
                shinyjs::disable('submit')
            } else {
                shinyjs::enable('submit')
            }
        })

        observeEvent(input$submit, {
            record <- map(names(attributes), function(p) { input[[p]] })
            names(record) <- names(attributes)
            result$record(record)
            result$saveTrigger(result$saveTrigger() + 1)
            removeModal()
        })

        result
    }
}
