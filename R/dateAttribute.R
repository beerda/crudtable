#' @export
dateAttribute <- function(id,
                          label = id,
                          validator = NULL,
                          readOnly = FALSE,
                          ...) {
    attribute(id = id,
              label = label,
              validator = validator,
              typecast = typecastDateToNumeric(),
              readOnly = readOnly,
              input = function(ns) {
                  dateInput(ns(id), label = label, ...)
              })
}
