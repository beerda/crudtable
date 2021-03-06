% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formServerFactory.R
\name{formServerFactory}
\alias{formServerFactory}
\title{A factory that creates a server-side function that handles the \code{\link{formUI}}.}
\usage{
formServerFactory(dao, validators = list())
}
\arguments{
\item{dao}{A data access object (DAO), see \code{\link{dao}}, whose attributes are to be obtained
from the form and provide to the \code{\link{crudTableServer}}.}

\item{validators}{A list of validators that validate the user input and show an error message,
see \code{\link{validator}}.}
}
\value{
A function that is used by shiny to handle the inputs of the form. The returned function
  expects three arguments: \code{input}, \code{output} and \code{session}. It returns a list of
  three reactive values: \itemize{ \item \code{saveTrigger}, which triggers by this function on
  submit of the form, after the data are stored into the \code{record} reactive value; \item
  \code{loadTrigger}, which expects to be triggerred by \code{\link{crudTableServer}} after the form
  data are prepared in the \code{record} reactive value in order to load them into the form;
  \item \code{record} the list of data values to be passed to/from the form. }
}
\description{
This factory creates a function that handles the server-side functionality of the
\code{\link{formUI}}. It is responsible for loading data into the form for editing, collecting
the data after submitting them by the user and validating the user input.
}
\details{
The purpose of the created function is to be passed as the 'formServer' argument for the
\code{\link{crudTableServer}} module.
}
\seealso{
\code{\link{formUI}}, \code{\link{crudTableServer}}, \code{\link{validator}}
}
