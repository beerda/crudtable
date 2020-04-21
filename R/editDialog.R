#' Edit dialog for the create and update operations of the \code{\link{crudTable}}
#'
#' @param id Shiny module identifier of the edit dialog as set by the \code{\link{crudTable}}. (The id is based on
#'     the \code{\link{crudTable}}'s namespace and ends either with \code{"newForm"} or \code{"editForm"} accordingly
#'     to whether the dialog is used for new data input or existing data update.)
#' @param ... The definition of the edit dialog, i.e. the shiny input elements whose IDs must be named after
#'     the attribute names, as expected by the DAO (see \code{\link{dataFrameDao}} or \code{\link{sqlDao}} for
#'     more information on Data Access Objects). IDs must also be namespaced, as need by the UI modules, see
#'     the example below.
#' @param newTitle A dialog title used for new data input
#' @param editTitle A dialog title used for existing data update
#' @param submitLabel Label of the submit button
#' @param cancelLabel Label of the cancel button
#'
#' @examples
#' \dontrun{
#' # A typical use of editDialog - create a form UI for the crudTable:
#' formUI <- function(id) {
#'    # create namespace - note the use of ns() below in *Input calls
#'    ns <- NS(id)
#'    editDialog(id,
#'               textInput(ns('Plant'), 'Plant'),
#'               selectInput(ns('Type'), 'Type', choices = c('Quebec', 'Mississippi')),
#'               selectInput(ns('Treatment'), 'Treatment', choices = c('nonchilled', 'chilled')),
#'               numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]', value = 100, min = 50, max = 1000),
#'               numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]', value = 0, min = 0, max = 100),
#'    )
#' }
#' }
#' @seealso crudTable
#' @export
editDialog <- function(id, ...,
                       newTitle = 'New',
                       editTitle = 'Edit',
                       submitLabel = 'Submit',
                       cancelLabel = 'Cancel') {
    ns <- NS(id)
    title <- ifelse(endsWith(id, '-newForm'), newTitle, editTitle)
    modalDialog(...,
                title = title,
                footer = list(
                    modalButton(cancelLabel),
                    actionButton(ns('submit'), submitLabel)
                ))
}
