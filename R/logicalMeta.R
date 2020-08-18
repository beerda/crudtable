#' @export
logicalMeta <- function(id,
                        label = id,
                        validator = NULL,
                        readOnly = FALSE,
                        ...) {
    meta(id = id,
         label = label,
         validator = validator,
         typecast = NULL,
         readOnly = readOnly,
         input = function(ns) {
             checkboxInput(ns(id), label = label, ...)
         })
}
