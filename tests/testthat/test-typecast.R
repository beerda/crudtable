test_that("typecast", {
    tt <- typecast(fromInternal = min,
                   toInternal = max)
    expect_true(is.typecast(tt))
    expect_equal(tt$fromInternal, min)
    expect_equal(tt$toInternal, max)
})
