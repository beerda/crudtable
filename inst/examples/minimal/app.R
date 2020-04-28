library(shiny)
library(crudtable)

# Create Data Access Object
dao <- dataFrameDao(CO2)

# User Interface
ui <- fluidPage(
    crudTableUI('crud')
)

# Server-side
server <- function(input, output, session) {
    callModule(crudTable, 'crud', dao)
}

# Run the shiny app
shinyApp(ui = ui, server = server)
