test_that("return.levels.mev", {
  describe("return.levels.mev", {
    
    it("should correctly calculate SMEV return levels for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2005-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      result <- return.levels.mev(fsmev(data))
      # Check if the result has the expected structure
      expect_true("rl" %in% names(result))
    })
    
    it("should correctly calculate MEV return levels for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2005-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      result <- return.levels.mev(fmev(data))
      # Check if the result has the expected structure
      expect_true("rl" %in% names(result))
    })
    
    it("should correctly calculate TMEV return levels for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2010-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      result <- return.levels.mev(ftmev(data, minyears = 8))
      # Check if the result has the expected structure
      expect_true("rl" %in% names(result))
    })
    
    #---------------------------------------------
    # confidence intervals use parallel processing
    it("should correctly calculate confidence intervals for SMEV return levels for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2005-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- fsmev(data)
      result <- return.levels.mev(fit, ci = TRUE, alpha = 0.2, R = 10)
      # Check if the result has the expected structure
      expect_true("rl" %in% names(result))
      expect_true("ci" %in% names(result))
    })
    
    it("should correctly calculate confidence intervals for MEV return levels for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2005-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- fmev(data)
      result <- return.levels.mev(fit, ci = TRUE, alpha = 0.2, R = 10)
      # Check if the result has the expected structure
      expect_true("rl" %in% names(result))
      expect_true("ci" %in% names(result))
    })
    
    it("should correctly calculate confidence intervals for TMEV return levels for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2010-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- ftmev(data, minyears = 7)
      result <- return.levels.mev(fit, ci = TRUE, alpha = 0.2, R = 10)
      # Check if the result has the expected structure
      expect_true("rl" %in% names(result))
      expect_true("ci" %in% names(result))
    })
    
  })
})
