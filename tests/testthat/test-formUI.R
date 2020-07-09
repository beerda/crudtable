test_that("formUI newForm", {
    res <- formUI(id = 'theID-newForm',
                  newTitle = 'theNewTitle',
                  editTitle = 'theEditTitle',
                  submitLabel = 'theSubmitLabel',
                  cancelLabel = 'theCancelLabel')

    res <- unlist(res, recursive = TRUE, use.names = FALSE)

    expect_true(any(res == 'theNewTitle'))
    expect_true(all(res != 'theEditTitle'))
    expect_true(any(res == 'theSubmitLabel'))
    expect_true(any(res == 'theCancelLabel'))
})


test_that("formUI editForm", {
    res <- formUI(id = 'theID-editForm',
                  newTitle = 'theNewTitle',
                  editTitle = 'theEditTitle',
                  submitLabel = 'theSubmitLabel',
                  cancelLabel = 'theCancelLabel')

    res <- unlist(res, recursive = TRUE, use.names = FALSE)

    expect_true(all(res != 'theNewTitle'))
    expect_true(any(res == 'theEditTitle'))
    expect_true(any(res == 'theSubmitLabel'))
    expect_true(any(res == 'theCancelLabel'))
})
