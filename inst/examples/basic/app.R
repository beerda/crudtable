library(shiny)
library(crudtable)


# Create Data Access Object
dao <- dataFrameDao(CO2)

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
