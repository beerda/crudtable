test_that("typecastDateToNumeric", {
    tc <- typecastDateToNumeric()
    expect_equal(tc$toInternal(as.Date('2010-12-24')), 14967)
    expect_equal(tc$fromInternal(14967), as.Date('2010-12-24'))
})
