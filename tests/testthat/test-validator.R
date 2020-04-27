test_that("validator", {
    v <- validator(letters[1:3], LETTERS[1:3], is.na)

    expect_true(is.validator(v))
    expect_equal(length(v), 3)
    expect_equal(names(v), letters[1:3])

    expect_equal(class(v[[1]]), 'validator')
    expect_equal(class(v[[2]]), 'validator')
    expect_equal(class(v[[3]]), 'validator')
    expect_equal(v[[1]]$errorMessage, 'A')
    expect_equal(v[[2]]$errorMessage, 'B')
    expect_equal(v[[3]]$errorMessage, 'C')
    expect_equal(v[[1]]$f, is.na)
    expect_equal(v[[2]]$f, is.na)
    expect_equal(v[[3]]$f, is.na)
})


test_that("filledValidator", {
    v <- filledValidator(letters[1:3])

    expect_true(is.validator(v))
    expect_equal(length(v), 3)
    expect_equal(names(v), letters[1:3])
    expect_equal(class(v[[1]]), 'validator')
    expect_equal(class(v[[2]]), 'validator')
    expect_equal(class(v[[3]]), 'validator')

    expect_true(v[[1]]$f('xyz'))
    expect_true(v[[1]]$f(123))
    expect_true(v[[1]]$f(FALSE))
    expect_true(v[[1]]$f(1:3))

    expect_equal(class(v[[1]]), 'validator')
    expect_false(v[[1]]$f(NULL))
    expect_false(v[[1]]$f(NA))
    expect_false(v[[1]]$f(''))
    expect_false(v[[1]]$f(c(1:3, NA)))
})
