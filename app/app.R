library(shiny)
library(DT)
library(tidyverse)

source('crudTableModule.R')


ui <- fluidPage(
    titlePanel('CRUD'),
    hr(),
    crudTableOutput('tab')
)


server <- function(input, output, session) {
    callModule(crudTable, 'tab')
}


shinyApp(ui = ui, server = server)
