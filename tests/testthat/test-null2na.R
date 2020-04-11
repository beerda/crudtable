test_that("null2na", {
    expect_equal(null2na('a'), 'a')
    expect_equal(null2na(NULL), NA)
})
