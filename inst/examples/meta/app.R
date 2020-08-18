library(shiny)
library(shinyjs)
library(crudtable)
library(DBI)
library(RSQLite)


#########################################################################
# 1. Static data initialization
#########################################################################

# Dictionary of services
servicePrices <- list(oil=150, tires=100, wash=30)


#########################################################################
# 2. Database initialization
#########################################################################

# Create an in-memory database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Register database cleanup on stop of the shiny app
shiny::onStop(function() { dbDisconnect(con) })

# Create an empty data frame
df <- data.frame(date=numeric(),
                 service=character(),
                 amount=numeric(),
                 discount=numeric(),
                 total=numeric(),
                 paid=logical())

# Save the data frame into SQLite as table 'invoice'
dbWriteTable(con, 'invoice', df)

# Create a Data Access Object
dao <- sqlDao(con,
              table = 'invoice',
              attributes = list(dateAttribute(id='date', 'Date', weekstart = 1, value = Sys.Date()),
                                factorAttribute(id='service', 'Service', choices=names(servicePrices)),
                                numericAttribute(id='price', 'Price', readOnly = TRUE, value = NA),
                                numericAttribute(id='amount', 'Amount', value = 1, min = 1, max = 10),
                                numericAttribute(id='discount', 'Discount (%)', value = 0, min = 0, max = 10),
                                numericAttribute(id='total', 'Total', readOnly=TRUE, value = NA, min = 0, max = 1000000),
                                logicalAttribute(id='paid', 'Paid', value = FALSE)))


#########################################################################
# 4. Initialize the default server-side form handler
#########################################################################

# Create standard edit form dialog handler that will be used in a custom handler
defaultFormServer <- formServerFactory(
    dao = dao,
    validators = c(
        validator('amount',
                  'Amount must be odd',
                  function(v) { !is.null(v) && !is.na(v) && v %% 2 != 0 }),
        filledValidator(names(dao$getAttributes()))
    )
)


#########################################################################
# 5. Create custom server-side form handler
#########################################################################

# Create custom edit form dialog handler
myFormServer <- function(input, output, session) {
    # first do the default behaviour
    res <- defaultFormServer(input, output, session)

    # then compute some input values
    observe({
        # must observe the load trigger to ensure the re-computation after data loading
        res$loadTrigger()

        # now we can compute some inputs
        service <- input$service
        amount <- input$amount
        discount <- input$discount
        if (!is.null(service)) {
            price <- servicePrices[[service]]
            total <- price * amount * (1 - discount / 100)
            updateNumericInput(session, 'price', value = price)
            updateNumericInput(session, 'total', value = total)
        }
    })

    # return the result of the default handler
    res
}


#########################################################################
# 6. Shiny app initialization
#########################################################################

# User Interface
ui <- fluidPage(
    titlePanel('Invoices'),
    hr(),
    crudTableUI('crud'),
    hr(),
    htmlOutput('summary')
)

# Server-side
server <- function(input, output, session) {
    dataChangeTrigger <- crudTableServer(id = 'crud',
                                         dao = dao,
                                         formServer = myFormServer)

    output$summary <- renderUI({
        dataChangeTrigger() # establish dependency on data change
        data <- dao$getData()
        tagList(
            'Sum of Total: ',
            tags$b(sum(data$total)),
            tags$br(),
            'Sum of Paid: ',
            tags$b(sum(data$total * data$paid))
        )
    })
}

# Run the shiny app
shinyApp(ui = ui, server = server)
