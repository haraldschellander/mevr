test_that("fsmev", {
  describe("fsmev function", {
    
    it("should throw an error if data is not a data.frame", {
      expect_error(fsmev(list(1, 2)), "data must be of class 'data.frame'")
    })
    
    it("should throw an error if date column is not of class 'Date'", {
      data <- data.frame(groupvar = c("2024-01-01", "2025-01-01"), val = c(10, 20))
      expect_error(fsmev(data), "date column must be of class 'Date'")
    })
    
    it("should throw an error if data values are not of class 'numeric'", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, "20"))
      expect_error(fsmev(data), "data values must be of class 'numeric'")
    })
    
    it("should throw an error if data contains negative values", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(-10, 20))
      expect_error(fsmev(data), "data must not contain values < 0")
    })
    
    it("should throw a warning if data contains NA values", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, NA))
      expect_warning(fsmev(data), "data contains 1 NA values")
    })
    
    it ("should throw an error if censoring options are missing", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, 20))
      expect_error(fsmev(data, censor = TRUE, censor_opts = list(nrtrials = 10)), "thresholds for censoring must be provided")
      expect_error(fsmev(data, censor = TRUE, censor_opts = list(thresholds = 0.1)), "number of trials for censoring must be provided")
      expect_error(fsmev(data, censor = TRUE, censor_opts = list(thresholds = 0.1, nrtrials = 10)), "number of samples for censoring must be provided")
    })
    
    it("should correctly calculate SMEV parameters for valid input", {
      # Setup a mock dataset
      data <- data.frame(
        groupvar = as.Date(c("2024-01-01", "2024-02-01", "2025-01-01")),
        val = c(10, 15, 12)
      )
      result <- fsmev(data, threshold = 5)
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
    it("should correctly calculate SMEV parameters for method 'mle'", {
      # Setup a mock dataset
      data <- data.frame(
        groupvar = as.Date(c("2024-01-01", "2024-02-01", "2025-01-01")),
        val = c(10, 15, 12)
      )
      result <- fsmev(data, method = "mle")
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
    it("should correctly calculate SMEV parameters for method 'ls'", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2001-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data |>
        filter(val >= 0 & !is.na(val))
      result <- fsmev(data, method = "ls")
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
    it("should correctly calculate standard errors for method 'pwm'", {
      # Setup a mock dataset
      data <- data.frame(
        groupvar = as.Date(c("2024-01-01", "2024-02-01", "2025-01-01")),
        val = c(10, 15, 12)
      )
      result <- fsmev(data, sd = TRUE)
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      expect_true("std" %in% names(result))
      expect_true("varcov" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
    it("should correctly calculate standard errors for method 'mle'", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2001-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data |>
        filter(val >= 0 & !is.na(val))
      result <- fsmev(data, method = "mle", sd = TRUE)
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      expect_true("std" %in% names(result))
      expect_true("varcov" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })
    
    it("should correctly calculate standard errors for method 'ls'", {
      # Setup a mock dataset
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2001-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data |>
        filter(val >= 0 & !is.na(val))
      result <- fsmev(data, method = "ls", sd = TRUE)
      # Check if the result has the expected structure
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      expect_true("std" %in% names(result))
      expect_true("varcov" %in% names(result))
      # Add more assertions based on what you expect the output to be
    })

    it("should throw an error if method of standard error calculation is not 'boot'", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, 20))
      expect_error(fsmev(data, sd = TRUE, sd.method = "ana"), "only method 'boot' is allowed for calculation of standard errors")
    })
    
    it("should correctly calculate SMEV parameters for censored input", {
      data("dailyrainfall")
      result <- fsmev(dailyrainfall, censor = TRUE, censor_opts = list(thresholds = c(0.1, 0.5, 0.9), nrtrials = 1, R = 100))
      expect_true("c" %in% names(result))
      expect_true("w" %in% names(result))
      expect_true("n" %in% names(result))
      #expect_true("method" == "censored lsreg")
    })
    
  })
})
