test_that("fmev", {
  describe("fmev function", {
    
    it("should throw an error if data is not a data.frame", {
      expect_error(fmev(list(1, 2), threshold = 0), "data must be of class 'data.frame'")
    })
    
    it("should throw an error if date column is not of class 'Date'", {
      data <- data.frame(groupvar = c("2024-01-01", "2025-01-01"), val = c(10, 20))
      expect_error(fmev(data, threshold = 0), "date column must be of class 'Date'")
    })
    
    it("should throw an error if data values are not of class 'numeric'", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, "20"))
      expect_error(fmev(data), "data values must be of class 'numeric'")
    })
    
    it("should throw an error if data contains negative values", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(-10, 20))
      expect_error(fmev(data, threshold = 0), "data must not contain values < 0")
    })
    
    it("should throw a warning if data contains NA values", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, NA))
      expect_warning(fmev(data), "data contains 1 NA values")
    })
    
    it ("should throw an error if method != 'pwm' and threshold > 0", {
        data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, 20))
        expect_error(fmev(data, threshold = 1, method = "mle"), "threshold can only be used for method 'pwm'")
    })
    
    it("should correctly calculate MEV parameters for valid input", {
      # Setup a mock dataset
      data <- data.frame(
        groupvar = as.Date(c("2024-01-01", "2024-02-01", "2025-01-01")),
        val = c(10, 15, 12)
      )
      result <- fmev(data, threshold = 5)
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
    it("should correctly calculate MEV parameters for method 'mle'", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2010-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      result <- fmev(data, method = "mle")
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
    })
    
    it("should correctly calculate MEV parameters for method 'ls'", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2001-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      result <- fmev(data, method = "ls")
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
    })
    
  })
})
