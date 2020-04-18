#' Creates a data table view that allows to add new data, modify existent records or delete the records.
#'
#' @param id The ID of the widget
#' @param newButtonLabel Label of the button for adding of new records. If 'NULL', the button is not shown.
#' @param newButtonIcon Icon of the button for adding of new records
#' @param newButtonClass Class of the button for adding of new records
#' @param newButtonWidth The width of the button, e.g. '400px' or '100%'
#' @return An editable data table widget
#' @export
crudTableUI <- function(id,
                        newButtonLabel = 'New Record',
                        newButtonIcon = icon('plus'),
                        newButtonClass = 'btn-primary',
                        newButtonWidth = NULL) {
    assert_that(is_scalar_character(id))
    assert_that(is.null(newButtonLabel) || is_scalar_character(newButtonLabel))
    assert_that(is.null(newButtonClass) || is_scalar_character(newButtonClass))
    assert_that(is.null(newButtonWidth) || is_scalar_character(newButtonWidth))

    ns <- NS(id)
    args <- list(
        shinyFeedback::useShinyFeedback(),
        shinyjs::useShinyjs()
    )
    if (!is.null(newButtonLabel)) {
        args <- c(args, list(
            actionButton(ns('newButton'),
                         label = newButtonLabel,
                         class = newButtonClass,
                         icon = newButtonIcon,
                         width = newButtonWidth),
            tags$br(),
            tags$br()
        ))
    }
    args <- c(args, list(
        DT::dataTableOutput(ns('table'))
    ))
    do.call(tagList, args)
}


.tableButton <- function(action, id, title, icon, session) {
    ns <- session$ns
    paste0('<button ',
           'class="btn btn-sm" ',
           'data-toggle="tooltip" ',
           'data-placement="top" ',
           'style="margin: 0" ',
           'title="', title, '" ',
           'onClick="Shiny.setInputValue(\'', ns(action), '\', ', id, ', { priority: \'event\' });">',
           '<i class="fa fa-', icon, '"></i>',
           '</button>')
}



#' @export
crudTable <- function(input, output, session, dao, formUI, formServer) {
    ns <- session$ns
    dataChangedTrigger <- reactiveVal(0)

    # ---- delete record ---------------------------------------

    observeEvent(input$deleteId, {
        id <- input$deleteId
        showModal(
            modalDialog('Are you sure you want to delete the record?',
                        footer = list(
                            modalButton('Cancel'),
                            actionButton(ns('deleteAction'), 'Delete')
                        )
            )
        )
    })

    observeEvent(input$deleteAction, {
        dao$delete(input$deleteId)
        dataChangedTrigger(dataChangedTrigger() + 1)
        removeModal()
    })

    # ---- new record ------------------------------------------

    observeEvent(input$newButton, {
        showModal(formUI(ns('newForm')))
    })

    newForm <- callModule(formServer, 'newForm')

    observeEvent(newForm$trigger(), ignoreInit = TRUE, {
        dao$insert(newForm$record())
        dataChangedTrigger(dataChangedTrigger() + 1)
    })

    # ---- edit record -----------------------------------------

    editForm <- callModule(formServer, 'editForm')

    observeEvent(input$editId, {
        id <- input$editId
        editForm$record(dao$getRecord(id))
        showModal(formUI(ns('editForm')))
    })

    observeEvent(editForm$trigger(), ignoreInit = TRUE, {
        dao$update(input$editId, editForm$record())
        dataChangedTrigger(dataChangedTrigger() + 1)
    })

    # ---- outputs ---------------------------------------------

    data <- reactive({
        dataChangedTrigger()
        dao$getData()
    })

    output$table <- DT::renderDataTable({
        d <- data()
        actions <- purrr::map_chr(d$id, function(id_) {
            paste0('<div class="btn-group" style="width: 75px;" role="group">',
                   .tableButton('editId', id_, 'Edit', 'edit', session),
                   .tableButton('deleteId', id_, 'Delete', 'trash-o', session),
                   '</div>'
            )
        })
        d <- cbind(data.frame(' ' = actions, check.names = FALSE, stringsAsFactors = FALSE),
                   d)
        DT::datatable(d,
                      rownames = FALSE,
                      selection = 'none',
                      escape = -1)  # escape HTML everywhere except the first column
    })
}
