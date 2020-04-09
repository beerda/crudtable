test_that("datadef default values loading", {
    res <- datadef(list(table='tab',
                        columns=list(a=list(), b=list())))
    expect_true(is.datadef(res))
    expect_equal(res,
                 list(table='tab',
                      columns=list(a=list(name='a', type='text', na=FALSE, persistent=TRUE),
                                   b=list(name='b', type='text', na=FALSE, persistent=TRUE))))

    res <- datadef(list(table='tab',
                              columns=list(a=list(name='Bla'), b=list(na=TRUE))))
    expect_true(is.datadef(res))
    expect_equal(res,
                 list(table='tab',
                      columns=list(a=list(name='Bla', type='text', na=FALSE, persistent=TRUE),
                                   b=list(na=TRUE, name='b', type='text', persistent=TRUE))))
})
