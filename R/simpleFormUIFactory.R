simpleFormUIFactory <- function(dao) {
    assert_that(is.dao(dao))

    attributes <- dao$getAttributes()

    function(id) {
        ns <- NS(id)
        widgets <- map(attributes, function(a) {
            textInput(ns(a), a)
        })
        do.call(formUI, c(list(id), widgets))
    }
}
