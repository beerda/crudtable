library(shiny)
library(crudtable)
library(RSQLite)


con <- dbConnect(RSQLite::SQLite(), ":memory:")
shiny::onStop(function() { dbDisconnect(con) })
dbWriteTable(con, 'CO2', as.data.frame(CO2))


def <- list(
    table='CO2',
    columns=list(Plant=list(),
                 Type=list(type='enum', levels=c('Quebec', 'Mississippi')),
                 Treatment=list(type='enum', levels=c('nonchilled', 'chilled')),
                 conc=list(name='Ambient CO2 concentration [mL/L]', type='numeric', min=50, max=1000),
                 uptake=list(name='CO2 uptake rates [umol/m2 sec]', type='numeric', min=0, max=100))
)
dao <- sqlDao(con, def)
form <- simpleForm(def)


ui <- fluidPage(
    titlePanel('crudtable example'),
    hr(),
    crudTableUI('crud')
)


server <- function(input, output, session) {
    callModule(crudTable, 'crud', dao, form$ui, form$server)
}


shinyApp(ui = ui, server = server)
