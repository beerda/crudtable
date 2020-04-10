#' @export
crudTableUI <- function(id) {
    ns <- NS(id)
    tagList(
        actionButton(ns('newButton'),
                     label='New Record',
                     class='btn-primary',
                     icon=icon('plus')),
        tags$br(),
        tags$br(),
        dataTableOutput(ns('table'))
    )
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
crudTable <- function(input, output, session, dao, formUI, form) {
    ns <- session$ns
    dataChangedTrigger <- reactiveVal(0)

    # ---- delete record ---------------------------------------

    observeEvent(input$deleteId, {
        id <- input$deleteId
        showModal(
            modalDialog('Are you sure you want to delete the record?',
                        footer=list(
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
        showModal(formUI(ns('newForm'), 'New'))
    })

    newForm <- callModule(form, 'newForm')

    observeEvent(newForm$trigger(), ignoreInit=TRUE, {
        dao$insert(newForm$record())
        dataChangedTrigger(dataChangedTrigger() + 1)
    })

    # ---- edit record -----------------------------------------

    observeEvent(input$editId, {
        id <- input$editId
        showModal(formUI(ns('editForm'), 'Edit'))
    })

    editForm <- callModule(form, 'editForm')

    observeEvent(editForm$trigger(), ignoreInit=TRUE, {
        dao$update(input$editId, editForm$record())
        dataChangedTrigger(dataChangedTrigger() + 1)
    })

    # ---- outputs ---------------------------------------------

    data <- reactive({
        dataChangedTrigger()
        dao$getData()
    })

    output$table <- renderDataTable({
        d <- data()
        actions <- purrr::map_chr(d$id, function(id_) {
            paste0('<div class="btn-group" style="width: 75px;" role="group">',
                   .tableButton('editId', id_, 'Edit', 'edit', session),
                   .tableButton('deleteId', id_, 'Delete', 'trash-o', session),
                   '</div>'
            )
        })
        d <- cbind(tibble(' '=actions), d)
        datatable(d,
                  rownames=FALSE,
                  selection='none',
                  escape=-1)  # escape HTML everywhere except the first column
    })
}
