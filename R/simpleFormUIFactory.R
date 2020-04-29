simpleFormUIFactory <- function(dao) {
    assert_that(is.dao(dao))

    attributes <- dao$getAttributes()

    function(id) {
        ns <- NS(id)
        widgets <- map(names(attributes), function(name) {
            a <- attributes[[name]]
            if (a$type == 'factor') {
                selectInput(ns(name), name, choices = a$levels)
            } else if (a$type == 'numeric') {
                numericInput(ns(name), name, value = NA)
            } else if (a$type == 'logical') {
                checkboxInput(ns(name), name)
            } else {
                textInput(ns(name), name, value = NA)
            }
        })
        do.call(formUI, c(list(id), widgets))
    }
}
