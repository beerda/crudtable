#' @export
dateMeta <- function(id,
                     label = id,
                     validator = NULL,
                     readOnly = FALSE,
                     ...) {
    meta(id = id,
         label = label,
         validator = validator,
         typecast = typecastDateToNumeric(),
         readOnly = readOnly,
         input = function(ns) {
             dateInput(ns(id), label = label, ...)
         })
}
