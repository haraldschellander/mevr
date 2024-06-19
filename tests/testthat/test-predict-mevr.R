test_that("predict.mevr", {
  describe("predict.mevr function", {
    
    set.seed(123)
    sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2010-01-01"), by = "day")
    sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
    sample_data$groupvar <- as.Date(sample_data$groupvar)
    sample_data <- sample_data %>%
      filter(val >= 0 & !is.na(val))
    
    # it("should throw an error if object is not a TMEV fit", {
    #   fit <- fsmev(sample_data)
    #   expect_error(predict.mevr(fit), "data object must be of type 'mevr'")
    # })
    
    it("should throw an error if type of fit is not 'tmev'", {
      fit <- fsmev(sample_data)
      expect_error(predict.mevr(fit), "fitted object must be of type 'tmev'")
    })
    
    it("should correctly predict TMEV parameters for valid input", {
      fit <- ftmev(sample_data, minyears = 8)
      result <- predict.mevr(fit)
      # Check if the result has the expected structure
      expect_true("year" %in% names(result))
      expect_true("yday" %in% names(result))
      expect_true("c.pred" %in% names(result))
      expect_true("w.pred" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
  })
})