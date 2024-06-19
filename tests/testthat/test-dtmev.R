test_that("dtmev", {
  describe("dtmev function", {
    it ("should throw an error if x argument is not a single numeric", {
      expect_error(dtmev(1:2, data.frame(1:3)), "x must be a single numeric")
    })
    
    it ("should throw an error if data argument is not of class 'data.frame'", {
      expect_error(dtmev(1, 1:3), "data must be of class 'data.frame'")
    })
    
    # it ("should throw an error if data argument has not necessary ingredients", {
    #   set.seed(123)
    #   sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2003-01-01"), by = 1)
    #   sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
    #   sample_data$groupvar <- as.Date(sample_data$groupvar)
    #   data <- sample_data %>%
    #     filter(val >= 0 & !is.na(val))
    #   fit <- ftmev(data, minyears = 3)
    #   result <- fit$data
    #   expect_true("c" %in% names(result))
    #   expect_true("w" %in% names(result))
    #   expect_true("year" %in% names(result))
    # })
  })
})
