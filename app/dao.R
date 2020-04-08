dao <- list(
    getData=function() {
        d <- as.data.frame(CO2)
        d$id <- seq_len(nrow(d))
        d
    },

    getRecord=function(id) {
        r <- as.list(CO2[id, ])
        n <- names(r)
        attributes(r) <- NULL
        names(r) <- n
        n
    },

    insert=function(record) {
        cat('Inserting:\n')
        str(record)
    },

    update=function(id, record) {
        cat('Updating ', id, ':\n')
        str(record)
    },

    delete=function(id) {
        cat('Deleting ', id, '\n')
    }
)
