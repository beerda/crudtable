library(shiny)
library(crudtable)
library(RSQLite)


# Create an in-memory database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Register database cleanup on stop of the shiny app
shiny::onStop(function() { dbDisconnect(con) })

# Create CO2 data table
dbWriteTable(con, 'CO2', as.data.frame(CO2[1:5, ]))

# Data definition
def <- list(
    table = 'CO2',
    columns=list(Plant = list(),
                 Type = list(type = 'enum', levels = c('Quebec', 'Mississippi')),
                 Treatment = list(type = 'enum', levels = c('nonchilled', 'chilled'), default = 'chilled'),
                 conc = list(name = 'Ambient CO2 concentration [mL/L]',
                             type = 'numeric', min = 50, max = 1000, default = 100),
                 uptake = list(name = 'CO2 uptake rates [umol/m2 sec]',
                               type = 'numeric', min = 0, max = 100))
)

# Create Data Access Object
dao <- sqlDao(con, def)

# Create simple edit form
form <- simpleForm(def)

# User Interface
ui <- fluidPage(
    titlePanel('crudtable example'),
    hr(),
    crudTableUI('crud')
)

# Server-side
server <- function(input, output, session) {
    callModule(crudTable, 'crud', dao, form)
}

# Run the shiny app
shinyApp(ui = ui, server = server)
