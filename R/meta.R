#' @export
meta <- function(id,
                 label = id,
                 validator = NULL,
                 typecast = NULL,
                 readOnly = FALSE,
                 input = NULL,
                 ...) {
    assert_that(is.string(id))
    assert_that(is.string(label))
    assert_that(is.validator(validator) || is.null(validator))
    assert_that(is.typecast(typecast) || is.null(validator))
    assert_that(is.function(input) || is.null(input))

    f <- input
    if (readOnly && !is.null(input)) {
        f <- function(ns) {
            disabled(input(ns))
        }
    }

    structure(list(id = id,
                   label = label,
                   validator = validator,
                   typecast = typecast,
                   input = f,
                   ...),
              class = 'meta')
}
