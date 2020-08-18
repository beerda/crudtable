#' @export
factorAttribute <- function(id,
                       label = id,
                       choices,
                       validator = NULL,
                       readOnly = FALSE,
                       ...) {
    attribute(id = id,
              label = label,
              validator = validator,
              typecast = NULL,
              readOnly = readOnly,
              input = function(ns) {
                  selectInput(ns(id), label = label, choices = choices, ...)
              })
}
