test_that("return.levels.mev", {
  describe("return.levels.mev function", {
    
    ### SMEV
    it ("should throw an error if return.periods are <= 1", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, 20))
      fit <- fsmev(data)
      expect_error(return.levels.mev(fit, return.periods = 1), "All return periods have to be > 1")
    })
    
    it("should correctly calculate return levels for given return periods", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, 20))
      fit <- fsmev(data)
      rp <- c(2, 10)
      result <- return.levels.mev(fit, return.periods = rp)
      expect_true("rl" %in% names(result))
      expect_true("rp" %in% names(result))
      expect_equal(length(rp), length(result$rl))
    })
    
    ### MEVD
    it ("should throw an error if return.periods are <= 1", {
      data <- data.frame(groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))), val = c(10, 20))
      fit <- fmev(data)
      expect_error(return.levels.mev(fit, return.periods = 1), "All return periods have to be > 1")
    })
    
    it("should correctly calculate return levels for given return periods", {
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2004-01-01"), by = 1)
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- fmev(data)
      rp <- c(2, 10)
      result <- return.levels.mev(fit, return.periods = rp)
      expect_true("rl" %in% names(result))
      expect_true("rp" %in% names(result))
      expect_equal(length(rp), length(result$rl))
    })
    
    ### TMEV
    it ("should throw an error if return.periods are <= 1", {
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2006-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- ftmev(data, minyears = 5)
      expect_error(return.levels.mev(fit, return.periods = 1), "All return periods have to be > 1")
    })
    
    it("should correctly calculate return levels for given return periods", {
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2006-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- ftmev(data, minyears = 5)
      rp <- c(2, 10)
      result <- return.levels.mev(fit, return.periods = rp)
      expect_true("rl" %in% names(result))
      expect_true("rp" %in% names(result))
      expect_equal(length(rp), length(result$rl))
    })
    
  })
})
