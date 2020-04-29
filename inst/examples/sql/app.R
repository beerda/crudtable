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
dao <- sqlDao(con, table = 'CO2')

# Create edit form dialog
myFormUI <- function(id) {
    ns <- NS(id)
    formUI(id,
        selectInput(ns('Plant'), 'Plant', choices = levels(CO2$Plant)),
        selectInput(ns('Type'), 'Type', choices = levels(CO2$Type)),
        selectInput(ns('Treatment'), 'Treatment', choices = levels(CO2$Treatment)),
        numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]', value = 100, min = 50, max = 1000),
        numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]', value = 0, min = 0, max = 100)
    )
}

# Create edit form dialog handler
myFormServer <- formServerFactory(dao)

# User Interface
ui <- fluidPage(
    titlePanel('crudtable example'),
    hr(),
    crudTableUI('crud')
)

# Server-side
server <- function(input, output, session) {
    callModule(crudTable, 'crud', dao, myFormUI, myFormServer)
}

# Run the shiny app
shinyApp(ui = ui, server = server)
