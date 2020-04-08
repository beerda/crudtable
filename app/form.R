formUI <- function(id, title) {
    ns <- NS(id)
    modalDialog(
        fluidRow(
            column(width=6,
                   textInput(ns("model"), 'Model', value = '')
            ),
            column(width=6,
                   numericInput(ns('wt'), 'Weight (lbs)', value = '', min = 0, step = 1)
            )
        ),
        title=title,
        footer=list(
            modalButton('Cancel'),
            actionButton(ns("submit"), 'Submit')
        )
    )
}


form <- function(input, output, session) {
    result <- list(trigger=reactiveVal(0),
                   record=reactiveVal(list(a=1, b=2)))

    observeEvent(input$submit, {
        result$trigger(result$trigger() + 1)
        removeModal()
    })

    result
}
