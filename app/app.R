library(shiny)
library(DT)
library(tidyverse)


ui <- fluidPage(
    titlePanel('CRUD'),
    hr(),
    actionButton('newButton', 'New Record',
                 class='btn-primary',
                 icon=icon('plus')),
    tags$br(),
    tags$br(),
    dataTableOutput("table")
)


server <- function(input, output) {
    showDeleteDialog <- function() {
        showModal(
            modalDialog('Are you sure you want to delete the record?',
                footer=list(
                    modalButton('Cancel'),
                    actionButton('deleteAction', 'Delete')
                )
            )
        )
    }

    showEditDialog <- function(action, title) {
        showModal(
            modalDialog(
                fluidRow(
                    column(width=6,
                        textInput("attrModel", 'Model', value = '')
                    ),
                    column(width=6,
                        numericInput( 'attrWt', 'Weight (lbs)', value = '', min = 0, step = 1)
                    )
                ),
                title=title,
                footer=list(
                    modalButton('Cancel'),
                    actionButton(action, 'Submit')
                )
            )
        )

    }

    data <- reactive({
        d <- CO2
        d$uid <- seq_len(nrow(d))
        d
    })

    observeEvent(input$deleteId, {
        id <- input$deleteId
        showDeleteDialog()
    })

    observeEvent(input$deleteAction, {
        print(paste0('Deleting ', input$deleteId))
        removeModal()
    })

    observeEvent(input$newButton, {
        showEditDialog('newAction', 'New')
    })

    observeEvent(input$newAction, {
        record <- list(model=input$attrModel,
                       wt=input$attrWt)
        print('Saving new')
        str(record)
        removeModal()
    })

    observeEvent(input$editId, {
        id <- input$editId
        showEditDialog('editAction', 'Edit')
    })

    observeEvent(input$editAction, {
        record <- list(id=input$editId,
                       model=input$attrModel,
                       wt=input$attrWt)
        print('Updating')
        str(record)
        removeModal()
    })

    tableButton <- function(action, id, title, icon) {
        paste0('<button ',
               'class="btn btn-sm" ',
               'data-toggle="tooltip" ',
               'data-placement="top" ',
               'style="margin: 0" ',
               'title="', title, '" ',
               'onClick="Shiny.setInputValue(\'', action, '\', ', id, ', { priority: \'event\' });">',
               '<i class="fa fa-', icon, '"></i>',
               '</button>')
    }

    output$table <- renderDataTable({
        d <- data()
        actions <- purrr::map_chr(d$uid, function(id_) {
            paste0('<div class="btn-group" style="width: 75px;" role="group">',
                   tableButton('editId', id_, 'Edit', 'edit'),
                   tableButton('deleteId', id_, 'Delete', 'trash-o'),
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


shinyApp(ui = ui, server = server)
