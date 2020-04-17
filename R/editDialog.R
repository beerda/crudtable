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
