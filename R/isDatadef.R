is.datadef <- function(x) {
    is.list(x) &&
        is.scalar(x$table) &&
        is.character(x$table) &&
        is.list(x$columns) &&
        length(x$columns) > 0 &&
        is.character(names(x$columns)) &&
        all(map_lgl(x$columns, is.list))
}
