#' @export
numericMeta <- function(id,
                        label = id,
                        value,
                        validator = NULL,
                        readOnly = FALSE,
                        ...) {
    meta(id = id,
         label = label,
         validator = validator,
         typecast = NULL,
         readOnly = readOnly,
         input = function(ns) {
             numericInput(ns(id), label = label, value = value, ...)
         })
}
