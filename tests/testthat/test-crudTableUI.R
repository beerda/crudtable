test_that("crudTableUI with the new button", {
    res <- crudTableUI('myCrudTableID',
                       newButtonLabel = 'myNewButtonLabel')

    res <- unlist(res, recursive = TRUE, use.names = FALSE)

    expect_true(any(res == 'myCrudTableID-newButton'))
    expect_true(any(res == 'myNewButtonLabel'))
    expect_true(all(res != 'New Record'))
    expect_true(any(res == 'myCrudTableID-table'))
})


test_that("crudTableUI without the new button", {
    res <- crudTableUI('myCrudTableID',
                       newButtonLabel = NULL)

    res <- unlist(res, recursive = TRUE, use.names = FALSE)

    expect_true(all(res != 'myCrudTableID-newButton'))
    expect_true(all(res != 'myNewButtonLabel'))
    expect_true(all(res != 'New Record'))
    expect_true(any(res == 'myCrudTableID-table'))
})
