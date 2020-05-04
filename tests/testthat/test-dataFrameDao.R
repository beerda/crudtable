test_that("dataFrameDao::getAttributes", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)

    expect_true(is.dao(dao))
    expect_equal(dao$getAttributes(),
                 list(Plant=list(type='factor',
                                 levels=levels(d$Plant)),
                      Type=list(type='factor',
                                levels=levels(d$Type)),
                      Treatment=list(type='factor',
                                     levels=levels(d$Treatment)),
                      conc=list(type='numeric'),
                      uptake=list(type='numeric')))
})


test_that("dataFrameDao::getData", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)

    expect_equal(dao$getData(), cbind(id=1:5, CO2[1:5, ]))

    d <- CO2[1:3, ]
    expect_equal(dao$getData(), cbind(id=1:5, CO2[1:5, ]))

    d <<- CO2[1:3, ]
    expect_equal(dao$getData(), cbind(id=1:5, CO2[1:5, ]))

    res <- dao$getData()
    res[1, 1] <- NA
    expect_equal(dao$getData(), cbind(id=1:5, CO2[1:5, ]))
})


test_that("dataFrameDao::getRecord", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)

    expect_equal(dao$getRecord(2), as.list(cbind(id=2, CO2[2, ])))
})


test_that("dataFrameDao::insert", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)
    dao$insert(as.list(CO2[6, ]))
    expect_equal(dao$getData(), cbind(id=1:6, CO2[1:6, ]))
})


test_that("dataFrameDao::insert to empty dataframe", {
    d <- CO2[0, ]
    dao <- dataFrameDao(d)
    dao$insert(as.list(CO2[6, ]))
    expected <- cbind(id=1, CO2[6, ])
    rownames(expected) <- NULL
    expect_equal(dao$getData(), expected)
})


test_that("dataFrameDao::update", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)
    dao$update(3, as.list(CO2[6, ]))
    exp <- cbind(id=1:5, CO2[c(1,2,6,4,5), ])
    rownames(exp) <- NULL
    expect_equal(dao$getData(), exp)
})


test_that("dataFrameDao::update non continuous ids", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)
    dao$delete(2)
    dao$update(3, as.list(CO2[6, ]))
    exp <- cbind(id=c(1,3:5), CO2[c(1,6,4,5), ])
    rownames(exp) <- NULL
    expect_equal(dao$getData(), exp)
})


test_that("dataFrameDao::delete", {
    d <- CO2[1:5, ]
    dao <- dataFrameDao(d)

    dao$delete(3)
    exp <- cbind(id=1:5, CO2[1:5, ])
    exp <- exp[-3, ]
    rownames(exp) <- NULL
    expect_equal(dao$getData(), exp)

    dao$delete(5)
    exp <- cbind(id=1:5, CO2[1:5, ])
    exp <- exp[c(-3, -5), ]
    rownames(exp) <- NULL
    expect_equal(dao$getData(), exp)
})


test_that("dataFrameDao with Date column", {
    d <- data.frame(date=as.Date(character(0)), name=character(0), stringsAsFactors = FALSE)
    dao <- dataFrameDao(d)
    dao$insert(list(date=Sys.Date(), name='john'))
    expectedDf <- data.frame(id=1, date=Sys.Date(), name='john', stringsAsFactors = FALSE)
    expectedList <- list(id=1, date=Sys.Date(), name='john')
    expect_equal(dao$getData(), expectedDf)
    expect_equal(dao$getRecord(1), expectedList)
})

