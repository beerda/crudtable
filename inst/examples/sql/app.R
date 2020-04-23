library(shiny)
library(crudtable)
library(DBI)
library(RSQLite)


# Create an in-memory database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Register database cleanup on stop of the shiny app
shiny::onStop(function() { dbDisconnect(con) })

# Create CO2 data table
dbWriteTable(con, 'CO2', as.data.frame(CO2[1:5, ]))

# Create Data Access Object
dao <- sqlDao(con,
              table = 'CO2',
              attributes = c('Plant', 'Type', 'Treatment', 'conc', 'uptake'))

# Create edit form dialog
formUI <- function(id) {
    ns <- NS(id)
    editDialogUI(id,
        textInput(ns('Plant'), 'Plant'),
        selectInput(ns('Type'), 'Type', choices = c('Quebec', 'Mississippi')),
        selectInput(ns('Treatment'), 'Treatment', choices = c('nonchilled', 'chilled')),
        numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]', value = 100, min = 50, max = 1000),
        numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]', value = 0, min = 0, max = 100),
    )
}

# Create edit form dialog handler
formServer <- editDialogServer(dao$getAttributes())

# User Interface
ui <- fluidPage(
    titlePanel('crudtable example'),
    hr(),
    crudTableUI('crud')
)

# Server-side
server <- function(input, output, session) {
    callModule(crudTable, 'crud', dao, formUI, formServer)
}

# Run the shiny app
shinyApp(ui = ui, server = server)
