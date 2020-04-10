#' @export
simpleForm <- function(def) {
    def <- datadef(def)
    persist <- map_lgl(def$columns, function(col) col$persistent)
    persist <-names(persist)[persist]

    list(
        ui=function(id, title) {
            ns <- NS(id)
            elements <- map(names(def$columns), function(colid) {
                col <- def$columns[[colid]]
                inputId <- ns(colid)
                if (col$type == 'numeric') {
                    numericInput(inputId,
                                 label=col$name,
                                 value=null2empty(col$default),
                                 min=null2na(col$min),
                                 max=null2na(col$max),
                                 step=null2na(col$step))
                } else if (col$type == 'enum') {
                    selectInput(inputId,
                                label=col$name,
                                choices=col$levels,
                                selected=col$default)
                } else {
                    textInput(inputId,
                              label=col$name,
                              value=null2empty(col$default))
                }
            })
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

            observeEvent(result$record(), {
                rec <- result$record()
                for (colid in persist) {
                    col <- def$columns[[colid]]
                    inputId <- colid
                    if (col$type == 'numeric') {
                        updateNumericInput(session, inputId, value=rec[[colid]])
                    } else if (col$type == 'enum') {
                        updateSelectInput(session, inputId, selected=rec[[colid]])
                    } else {
                        updateTextInput(session, inputId, value=rec[[colid]])
                    }
                }
            })

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
