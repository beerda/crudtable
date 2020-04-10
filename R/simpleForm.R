#' @export
simpleForm <- function(def) {
    def <- datadef(def)

    persist <- map_lgl(def$columns, function(col) col$persistent)
    persist <-names(persist)[persist]
    elements <- map(names(def$columns), function(colId) {
        col <- def$columns[[colId]]
        if (col$type == 'numeric') {
            numericInput(colId,  col$name, value='',
                         min=null2na(col$min), max=null2na(col$max), step=null2na(col$step))
        } else if (col$type == 'enum') {
            selectInput(colId, col$name, choices=col$levels)
        } else {
            textInput(colId, col$name, value='')
        }
    })

    list(
        ui=function(id, title) {
            ns <- NS(id)
            do.call(modalDialog,  c(elements, list(
                title=title,
                footer=list(
                    modalButton('Cancel'),
                    actionButton(ns("submit"), 'Submit')
                )
            )))
        },
        server=function(input, output, session) {
            result <- list(trigger=reactiveVal(0),
                           record=reactiveVal(NULL))

            observeEvent(input$submit, {
                record <- map(persist, function(p) { input[[p]] })
                names(record) <- persist
                result$record(record)
                result$trigger(result$trigger() + 1)
                removeModal()
            })

            result
        }
    )
}
