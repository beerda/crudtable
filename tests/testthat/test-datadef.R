test_that("datadef default values loading", {
    expect_equal(datadef(list(table='tab',
                              columns=list(a=list(), b=list()))),
                 list(table='tab',
                      columns=list(a=list(name='a', type='text', na=FALSE, persistent=TRUE),
                                   b=list(name='b', type='text', na=FALSE, persistent=TRUE))))

    expect_equal(datadef(list(table='tab',
                              columns=list(a=list(name='Bla'), b=list(na=TRUE)))),
                 list(table='tab',
                      columns=list(a=list(name='Bla', type='text', na=FALSE, persistent=TRUE),
                                   b=list(na=TRUE, name='b', type='text', persistent=TRUE))))
})
