test_that("sqlDao", {
    data <- data.frame(title=letters[1:5], value=2 * 1:5)
    con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
    DBI::dbWriteTable(con, 'test', data)

    dao <- sqlDao(con, 'test', c('title', 'value'))
    expect_true(is.list(dao))
    expect_true(inherits(dao, 'dao'))
    expect_true(is.dao(dao))
    expect_false(is.dao(list()))

    expect_equal(dao$getData(),
                 data.frame(id=1:5, title=letters[1:5], value=2 * 1:5, stringsAsFactors = FALSE))
    expect_equal(dao$getRecord(3),
                 list(id=3, title='c', value=6.0))
    expect_equal(dao$getRecord(10), NULL)

    res <- dao$insert(list(title='bz', value=8))
    expect_equal(res, 1)
    expect_equal(dao$getData(),
                 data.frame(id=1:6, title=c(letters[1:5], 'bz'), value=c(2 * 1:5, 8), stringsAsFactors = FALSE))

    res <- dao$delete(3)
    expect_equal(res, 1)
    expect_equal(dao$getData(),
                 data.frame(id=c(1,2,4,5,6),
                            title=c(letters[c(1,2,4,5)], 'bz'), value=c(2 * c(1,2,4,5), 8), stringsAsFactors = FALSE))

    res <- dao$delete(20)
    expect_equal(res, 0)
    expect_equal(nrow(dao$getData()), 5)

    res <- dao$update(2, list(title='aaa', value=1))
    expect_equal(res, 1)
    expect_equal(dao$getData(),
                 data.frame(id=c(1,2,4,5,6),
                            title=c('a', 'aaa', 'd', 'e', 'bz'), value=c(2, 1, 8, 10, 8), stringsAsFactors = FALSE))

    res <- dao$update(20, list(title='aaa', value=1))
    expect_equal(res, 0)
    expect_equal(dao$getData(),
                 data.frame(id=c(1,2,4,5,6),
                            title=c('a', 'aaa', 'd', 'e', 'bz'), value=c(2, 1, 8, 10, 8), stringsAsFactors = FALSE))

    DBI::dbDisconnect(con)
})
