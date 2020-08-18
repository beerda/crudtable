#' @export
formUIFactory <- function(dao, type = 'simple') {
    assert_that(is.dao(dao))

    type <- match.arg(type)
    meta <- dao$getMeta()

    if (type == 'simple') {
        f <- function(id) {
            ns <- NS(id)
            inputs <- map(meta, function(m) { m$input(ns) })
            do.call(formUI, c(list(id=id), inputs))
        }

    } else {
        stop('Unrecognized type of formUI: ', type)
    }

    f
}
