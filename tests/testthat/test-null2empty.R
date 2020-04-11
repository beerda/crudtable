test_that("null2empty", {
    expect_equal(null2empty('a'), 'a')
    expect_equal(null2empty(NULL), '')
})
