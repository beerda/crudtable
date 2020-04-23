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


#' Server-part of the CRUD table view module
#'
#' This is the server part of the module. It handles all the CRUD operations on data. For new record or existing
#' record editing, a modal dialog defined in 'formUI' and 'formServer' is opened. The data are accessed via
#' the 'dao' structure.
#'
#' @param input Shiny server-part input object
#' @param output Shiny server-part output object
#' @param session Shiny server-part session object
#' @param dao Data Access Object that provides the data handling operations, see e.g. \code{\link{sqlDao}}.
#' @param formUI A function that creates the data editing modal dialog typically by calling the
#'     \code{\link{editDialog}} function. See examples below.
#' @param formServer A function that handles the actions performed in the 'formUI' edit dialog. Typically, it is
#'     a function created with the \code{\link{editDialogServer}} factory. See examples below.
#' @return Returns a reactive object that triggers on any data change within the CRUD table.
#' @export
#' @examples
#' \dontrun{
#' library(shiny)
#' library(crudtable)
#'
#' # Create Data Access Object
#' dao <- dataFrameDao(CO2)
#'
#' # Create edit form dialog
#' formUI <- function(id) {
#'     ns <- NS(id)
#'     editDialog(id,
#'                textInput(ns('Plant'), 'Plant'),
#'                selectInput(ns('Type'), 'Type', choices = c('Quebec', 'Mississippi')),
#'                selectInput(ns('Treatment'), 'Treatment', choices = c('nonchilled', 'chilled')),
#'                numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]',
#'                             value = 100, min = 50, max = 1000),
#'                numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]',
#'                             value = 0, min = 0, max = 100),
#'     )
#' }
#'
#' # Create edit form dialog handler
#' formServer <- editDialogServer(dao$getAttributes())
#'
#' # User Interface
#' ui <- fluidPage(
#'     titlePanel('crudtable example'),
#'     hr(),
#'     crudTableUI('crud')
#' )
#'
#' # Server-side
#' server <- function(input, output, session) {
#'     callModule(crudTable, 'crud', dao, formUI, formServer)
#' }
#'
#' # Run the shiny app
#' shinyApp(ui = ui, server = server)
#' }
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

    dataChangedTrigger
}
