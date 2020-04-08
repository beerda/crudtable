library(shiny)
library(DT)
library(tidyverse)

source('dao.R')
source('crudTableModule.R')


ui <- fluidPage(
    titlePanel('CRUD'),
    hr(),
    crudTableOutput('tab')
)


server <- function(input, output, session) {
    callModule(crudTable, 'tab', dao)
}


shinyApp(ui = ui, server = server)
