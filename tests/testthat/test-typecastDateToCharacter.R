test_that("typecastDateToCharacter", {
    tc <- typecastDateToCharacter()
    expect_equal(tc$toInternal(as.Date('2010-12-24')), '2010-12-24')
    expect_equal(tc$fromInternal('2010-12-24'), as.Date('2010-12-24'))

    tc <- typecastDateToCharacter('%d. %m. %Y')
    expect_equal(tc$toInternal(as.Date('2010-12-24')), '24. 12. 2010')
    expect_equal(tc$fromInternal('24. 12. 2010'), as.Date('2010-12-24'))
})
