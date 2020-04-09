library(shiny)
library(DT)
library(tidyverse)
library(DBI)
library(RSQLite)

source('dao.R')
source('form.R')
source('crudTableModule.R')

ui <- fluidPage(
    titlePanel('CRUD'),
    hr(),
    crudTableOutput('tab')
)


server <- function(input, output, session) {
    callModule(crudTable, 'tab', dao, formUI, form)
}


shinyApp(ui = ui, server = server)
