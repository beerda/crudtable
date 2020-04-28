# crudtable

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

