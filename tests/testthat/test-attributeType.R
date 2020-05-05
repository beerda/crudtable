test_that("attributeType", {
    expect_equal(attributeType(numeric(3)),
                 list(type='numeric'))
    expect_equal(attributeType(character(0)),
                 list(type='character'))
    expect_equal(attributeType(as.Date(character(0))),
                 list(type='Date'))
})
