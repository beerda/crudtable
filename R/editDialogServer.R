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

        observeEvent(result$record(), {
            rec <- result$record()
            for (colid in attributes) {
                # update value of the input UI
                session$sendInputMessage(colid, list(value = rec[[colid]]))
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
