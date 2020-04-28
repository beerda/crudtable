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


#' Server-part of the CRUD table module
#'
#' This is the server-part of the module. It handles all the CRUD (Create, Read, Update, Delete)
#' operations on data. For new or existing data input, a modal dialog is opened that is defined by
#' the \code{formUI} and \code{formServer} arguments. The underlying data table is accessed via the
#' \code{\link{dao}} object.
#'
#' @param input The Shiny server-part input object
#' @param output The Shiny server-part output object
#' @param session The Shiny server-part session object
#' @param dao Data Access Object (\code{\link{dao}}) that provides the data storage operations, see
#'   e.g. \code{\link{sqlDao}} or \code{\link{dataFrameDao}}.
#' @param formUI A function that creates the edit form for the user's data input. Typically, it
#'   is a function based on \code{\link{formUI}}. See examples below.
#' @param formServer A server-side function dual to the \code{formUI} argument that handles the
#'   actions performed in the edit form. Typically, it is a function created with the
#'   \code{\link{formServerFactory}}. See examples below.
#' @return Returns a reactive object that triggers on any data change within the CRUD table.
#' @seealso crudTableUI
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
#' myFormUI <- function(id) {
#'     ns <- NS(id)
#'     formUI(id,
#'            textInput(ns('Plant'), 'Plant'),
#'            selectInput(ns('Type'), 'Type', choices = c('Quebec', 'Mississippi')),
#'            selectInput(ns('Treatment'), 'Treatment', choices = c('nonchilled', 'chilled')),
#'            numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]',
#'                         value = 100, min = 50, max = 1000),
#'            numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]',
#'                         value = 0, min = 0, max = 100),
#'     )
#' }
#'
#' # Create edit form dialog handler
#' myFormServer <- formServerFactory(dao)
#'
#' # User Interface
#' ui <- fluidPage(
#'     crudTableUI('crud')
#' )
#'
#' # Server-side
#' server <- function(input, output, session) {
#'     callModule(crudTable, 'crud', dao, myFormUI, myFormServer)
#' }
#'
#' # Run the shiny app
#' shinyApp(ui = ui, server = server)
#' }
crudTable <- function(input,
                      output,
                      session,
                      dao,
                      formUI = simpleFormUIFactory(dao),
                      formServer = formServerFactory(dao)) {
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

    newForm <- callModule(formServer, 'newForm')

    observeEvent(input$newButton, {
        newForm$loadTrigger(newForm$loadTrigger() + 1)
        showModal(formUI(ns('newForm')))
    })

    observeEvent(newForm$saveTrigger(), ignoreInit = TRUE, {
        dao$insert(newForm$record())
        dataChangedTrigger(dataChangedTrigger() + 1)
    })

    # ---- edit record -----------------------------------------

    editForm <- callModule(formServer, 'editForm')

    observeEvent(input$editId, {
        id <- input$editId
        editForm$record(dao$getRecord(id))
        editForm$loadTrigger(editForm$loadTrigger() + 1)
        showModal(formUI(ns('editForm')))
    })

    observeEvent(editForm$saveTrigger(), ignoreInit = TRUE, {
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
