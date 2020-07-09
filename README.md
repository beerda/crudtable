![crudtable build on
travis-ci.org](https://travis-ci.org/beerda/crudtable.svg?branch=master)
![crudtable build on
appveyor.com](https://ci.appveyor.com/api/projects/status/github/beerda/crudtable?branch=master&svg=true)
![crudtable code
coverage](https://codecov.io/gh/beerda/crudtable/branch/master/graph/badge.svg)
![crudtable in CRAN](http://www.r-pkg.org/badges/version/crudtable)

# crudtable

**crudtable** is an [R](https://www.r-project.org/) package that makes
it easy to develop an editable data table in
[Shiny](https://shiny.rstudio.com/) web applications. With
**crudtable**, the following operations may be easily achieved:

  - *CRUD* - **C**reate, **R**read, **U**pdate and **D**elete of data
    records in
    [DT](https://cran.r-project.org/web/packages/DT/index.html)
    DataTable and a modal edit dialog window;
  - *validation* - ensuring the correct format of the user input;
  - *database access* - storing the data into a database via the
    standardized [DBI](https://www.r-dbi.org/) package for
    [R](https://www.r-project.org/) or to a file.

## Live Demo

See the [live demo](https://beerda.shinyapps.io/crudtable/) of the
**crudtable** package.

## Getting Started

To install the latest development version from GitHub:

    install.packages("remotes")
    remotes::install_github("beerda/crudtable")

## A Minimal Working Example

A minimal Shiny app that uses **crudtable**:

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

First, a Data Access Object (DAO) is created with `dataFrameDao`. DAO is
a list structure that provides data access functions to the `crudTable`
user interface. In this example, a simple DAO is created that works with
an in-memory data frame `CO2`. Alternatively, an SQL database may be
connected with **crudtable**’s `sqlDao` DAO.

The UI part consists of `crudTableUI` that uses
[DT](https://cran.r-project.org/web/packages/DT/index.html)’s
`DataTable` to view the dataset. The **crudtable** UI also provides the
*New record*, *Edit record* and *Delete record* buttons.

The server part consists of the call of the `crudTable` module that
connects the `crudTableUI` with the DAO.

## An Advanced Example

All the aspects and capabilities of the **crudtable** package will be
shown in this advanced example, which covers:

  - access to an SQLite data table;
  - custom input form user interface;
  - validation of the user input;
  - how to store values that are, rather than directly entered by the
    user, obtained programmatically.

First of all, let us import all the needed packages:

    library(shiny)
    library(shinyjs)
    library(crudtable)
    library(DBI)
    library(RSQLite)

We need `DBI` and `RSQLite` for database access, and `shinyjs` for
JavaScript support.

Next, we initialize the in-memory SQLite database engine and register
the connection cleanup hook on stop of Shiny. We also create an empty
data frame `df` with columns: `date`, `service`, `amount`, `discount`,
`total` and `paid`. This data frame is saved into SQLite as table
`'invoice'`. We also create a Data Access Object (DAO) `dao` by calling
the `sqlDao()` function:

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
                  typecast = list(date=typecastDateToNumeric()))

Note also the `typecast` argument of the `sqlDao()` call: it causes the
internally numeric attribute `date` to be type casted into `Date`. Such
workaround is needed because the DBI interface does not support such
complex data types as `Date`.

For our convenience, we also create a constant list of service prices
that will be used to populate the select box with values:

    # Dictionary of services
    servicePrices <- list(oil=150, tires=100, wash=30)

We also want a custom edit dialog window with some pre-defined values
and well defined ranges for numeric inputs. We also add two read only
input lines that will present some computed values to the user. For
that, we use the `disabled()` function of the `shinyjs` package. Note
also the namespacing of the input IDs by the `ns()` function, which is
mandatory:

    # Create edit form dialog
    myFormUI <- function(id) {
        ns <- NS(id)
        formUI(id,
            dateInput(ns('date'), 'Date', weekstart = 1, value = Sys.Date()),
            selectInput(ns('service'), 'Service', choices = names(servicePrices)),
            disabled(
                numericInput(ns('price'), 'Unit price', value = NA)
            ),
            numericInput(ns('amount'), 'Amount', value = 1, min = 1, max = 10),
            numericInput(ns('discount'), 'Discount (%)', value = 0, min = 0, max = 10),
            disabled(
                numericInput(ns('total'), 'Total', value = NA, min = 0, max = 1000000)
            ),
            checkboxInput(ns('paid'), 'Paid', value = FALSE)
        )
    }

After the edit form UI is defined, we need to create the server part of
the form handler. Since we want to perform a lot of custom
functionality, we code the server part in two steps. First, a default
form server handler is initialized by calling the `formServerFactory()`
function:

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

`formServerFactory()` requires `dao` and a definition of `validators`.
Validator is a mechanism for restricting the input to certain criteria.
If the user insert invalid input, an error message is shown and the edit
form dialog can not be submitted. In the piece of code above, we define
two types of validators: a custom validator bound to the `amount` data
input, which tests the oddness of the value. The second validator is
`filledValidator` that ensures the data inputs are filled.
`filledValidator` is bound to all data inputs - we call
`names(dao$getAttributes())` instead of enumerating names of all data
columns.

Now we can define our server-side handler of the edit form. First,
`defaultFormServer` handler must be called, which returns a list of
useful reactive values and triggers. After that, we can provide an
observer that computes the read only inputs of the form. Note that we
need to observe the `res$loadTrigger()` here, which triggers everytime
the data get loaded into the edit form. This ensures that the computed
values are initialized properly too. Note also that the server-side
handler must return the `res`, which is the result of
`defaultFormServer`:

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

And that’s nearly all. The last step is the initialization of the Shiny
app. We use `crudTableUI` on the client side and we call the
`crudTableServer` function on the server side. The latter gets `dao`,
`myFormUI` and `myFormServer` as arguments. Note also that the
`crudTableServer` function returns a reactive value that changes
everytime the CRUD table widget changes the data. That reactive value
can be used to trigger update of output widgets that rely on the data,
as can be seen below.

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
        dataChangeTrigger <- crudTableServer('crud', dao, myFormUI, myFormServer)
    
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

Note that it is not needed to call the `useShinyjs()` function in the UI
of the Shiny application since the **crudtable** package does it
internally by itself.

The complete advanced example is as follows:

    library(shiny)
    library(shinyjs)
    library(crudtable)
    library(DBI)
    library(RSQLite)
    
    
    #########################################################################
    # 1. Database initialization
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
                  typecast = list(date=typecastDateToNumeric()))
    
    
    #########################################################################
    # 2. Static data initialization
    #########################################################################
    
    # Dictionary of services
    servicePrices <- list(oil=150, tires=100, wash=30)
    
    
    #########################################################################
    # 3. Edit form user interface definition
    #########################################################################
    
    # Create edit form dialog
    myFormUI <- function(id) {
        ns <- NS(id)
        formUI(id,
            dateInput(ns('date'), 'Date', weekstart = 1, value = Sys.Date()),
            selectInput(ns('service'), 'Service', choices = names(servicePrices)),
            disabled(
                numericInput(ns('price'), 'Unit price', value = NA)
            ),
            numericInput(ns('amount'), 'Amount', value = 1, min = 1, max = 10),
            numericInput(ns('discount'), 'Discount (%)', value = 0, min = 0, max = 10),
            disabled(
                numericInput(ns('total'), 'Total', value = NA, min = 0, max = 1000000)
            ),
            checkboxInput(ns('paid'), 'Paid', value = FALSE)
        )
    }
    
    
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
        dataChangeTrigger <- crudTableServer('crud', dao, myFormUI, myFormServer)
    
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

Enjoy.
