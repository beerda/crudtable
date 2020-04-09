.datadefDefaults <- list(
    type='text',
    na=FALSE,
    persistent=TRUE
)


#' @export
datadef <- function(def=NULL, table=NULL, columns=NULL) {
    res <- NULL
    if (is.list(def)) {
        assert_that(is.null(table))
        assert_that(is.null(columns))
        res <- def
    } else {
        assert_that(is.null(def))
        res <- list(table=table, columns=columns)
    }
    assert_that(is.scalar(res$table) && is.character(res$table))
    assert_that(is.list(res$columns))
    assert_that(is.character(names(res$columns)))

    colnames <- names(res$columns)
    res$columns <- map(colnames, function(n) {
        r <- res$columns[[n]]
        if (length(r) > 0 && is.null(names(r))) {
            stop('Column definition must be a named list')
        }
        if (is.null(r[['name']])) {
            r$name <- n
        }
        i <- setdiff(names(.datadefDefaults), names(r))
        r <- c(r, .datadefDefaults[i])
        r
    })
    names(res$columns) <- colnames

    res
}
