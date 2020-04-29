library(shiny)
library(crudtable)


# Create Data Access Object
dao <- dataFrameDao(CO2)

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
