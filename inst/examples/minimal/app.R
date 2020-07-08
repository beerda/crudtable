library(shiny)
library(crudtable)

# Data Access Object from the CO2 data frame
dao <- dataFrameDao(CO2)

# User Interface
ui <- fluidPage(
    crudTableUI('crud')
)

# Server-side
server <- function(input, output, session) {
    crudTableServer('crud', dao)
}

# Run the shiny app
shinyApp(ui = ui, server = server)
