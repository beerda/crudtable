crudtable
=========

![crudtable build on
travis-ci.org](https://travis-ci.org/beerda/crudtable.svg?branch=master)
![crudtable build on
appveyor.com](https://ci.appveyor.com/api/projects/status/github/beerda/crudtable?branch=master&svg=true)
![crudtable code
coverage](https://codecov.io/gh/beerda/crudtable/branch/master/graph/badge.svg)
![crudtable in CRAN](http://www.r-pkg.org/badges/version/crudtable)

**crudtable** is an [R](https://www.r-project.org/) package that makes
easy tabular data input in [Shiny](https://shiny.rstudio.com/) web
applications. With **crudtable**, the following operations may be easily
achieved:

-   *CRUD* - **C**reate, **R**read, **U**pdate and **D**elete of data
    records in
    [DT](https://cran.r-project.org/web/packages/DT/index.html)
    DataTable and a modal edit dialog window;
-   *validation* - ensuring the correct format of the user input;
-   *database access* - storing the data into a database via the
    standardized [DBI](https://www.r-dbi.org/) package for
    [R](https://www.r-project.org/) or to a file.

Getting Started
---------------

To install the latest development version from GitHub:

    install.packages("remotes")
    remotes::install_github("beerda/crudtable")

How to Use
----------

### A Minimal Working Example

A minimal Shiny app that uses **crudtable**:

    library(shiny)
    library(crudtable)

    # Create DAO (Data Access Object) from the CO2 data frame
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

First, a Data Access Object (DAO) is created with `dataFrameDao`. DAO is
a list structure that provides data access functions to the `crudTable`
user interface. In this example, a simple DAO is created that works with
an in-memory data frame `CO2`. Alternatively, a SQL database may be
connected with **crudtable**’s `sqlDao` DAO.

The UI part consists of `crudTableUI` that uses
[DT](https://cran.r-project.org/web/packages/DT/index.html)’s
`DataTable` to view the dataset. The **crudtable** UI also provides the
*New record*, *Edit record* and *Delete record* buttons.

The server part consists of the call of the `crudTable` module that
connects the `crudTableUI` with the DAO.

### An Advanced Example

All the aspects and capabilities of the **crudtable** package will be
shown in this advanced example, which covers:

-   access to an SQLite data table;
-   custom input form user interface;
-   validation of the user input;
-   how to store values that are, rather than directly entered by the
    user, obtained programmatically.
