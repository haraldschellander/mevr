test_that("ftmev", {
  describe("ftmev function", {
    
    it("should throw an error if data is not a data.frame", {
      expect_error(ftmev(list(1, 2), threshold = 0), "data must be of class 'data.frame'")
    })
    
    it("should throw an error if date column is not of class 'Date'", {
      data <- data.frame(groupvar = c("2024-01-01", "2025-01-01"), val = c(10, 20))
      expect_error(ftmev(data, threshold = 0), "date column must be of class 'Date'")
    })
    
    it("should throw an error if data contains negative values", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(-10, 20))
      expect_error(ftmev(data, threshold = 0), "data must not contain values < 0")
    })
    
    it("should throw a warning if data contains NA values", {
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2006-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      data$val[1] <- NA
      expect_warning(ftmev(data, minyears = 5), "data contains 1 NA values")
    })
    
    it("should throw an error if data has less years than expected", {
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2002-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      expect_error(ftmev(data, minyears = 10), "data must have at least 10 years, but has only 2")
    })
    
    it("should correctly calculate TMEV parameters for valid input", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2006-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      result <- ftmev(data, threshold = 0, minyears = 5)
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
    })
    
  })
})