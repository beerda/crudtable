# crudtable

![crudtable build on travis-ci.org](https://travis-ci.org/beerda/crudtable.svg?branch=master)
![crudtable build on appveyor.com](https://ci.appveyor.com/api/projects/status/github/beerda/crudtable?branch=master&amp;svg=true)
![crudtable code coverage](https://codecov.io/gh/beerda/crudtable/branch/master/graph/badge.svg)
![crudtable in CRAN](http://www.r-pkg.org/badges/version/crudtable)

**crudtable** is an [R](https://www.r-project.org/) package that makes easy tabular data input in
[Shiny](https://shiny.rstudio.com/) web applications. With **crudtable**, the following operations
may be easily achieved:

* **C**reate, **R**read, **U**pdate and **D**elete of data records in
  [DT](https://cran.r-project.org/web/packages/DT/index.html) DataTable and a modal edit dialog
  window;
* validation of the user input;
* storing the data into a database via the standardized [DBI](https://www.r-dbi.org/) package
  for [R](https://www.r-project.org/) or to a file.
  
  

## Getting started

To install the latest development version from GitHub:

```
install.packages("remotes")
remotes::install_github("beerda/crudtable")
```


## How to use

### A Minimal Working Example

A minimal Shiny app that uses **crudtable**:

```
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
```

