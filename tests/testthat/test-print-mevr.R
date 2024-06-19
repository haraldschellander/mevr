test_that("print.mevr", {
  describe("print.mevr function", {
    
    it("should correctly print arguments for SMEV fit", {
      data <- data.frame(
        groupvar = as.Date(c("2024-01-01", "2024-02-01", "2025-01-01")),
        val = c(10, 15, 12)
      )
      fit <- fsmev(data)
      expect_true("c" %in% names(fit))
      expect_true("w" %in% names(fit))
      expect_true("n" %in% names(fit))
      expect_true("params" %in% names(fit))
      expect_true("maxima" %in% names(fit))
      expect_true("data" %in% names(fit))
      expect_true("years" %in% names(fit))
      expect_true("threshold" %in% names(fit))
      expect_true("method" %in% names(fit))
      expect_true("type" %in% names(fit))
    })
    
    it("should correctly print arguments for MEVD fit", {
      data <- data.frame(
        groupvar = as.Date(c("2024-01-01", "2024-02-01", "2025-01-01")),
        val = c(10, 15, 12)
      )
      fit <- fmev(data)
      expect_true("c" %in% names(fit))
      expect_true("w" %in% names(fit))
      expect_true("n" %in% names(fit))
      expect_true("params" %in% names(fit))
      expect_true("maxima" %in% names(fit))
      expect_true("data" %in% names(fit))
      expect_true("years" %in% names(fit))
      expect_true("threshold" %in% names(fit))
      expect_true("method" %in% names(fit))
      expect_true("type" %in% names(fit))
    })
    
    it("should correctly print arguments for TMEV fit", {
      set.seed(123)
      sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2006-01-01"), by = "day")
      sample_data <- data.frame(groupvar = sample_dates, val = sample(rnorm(length(sample_dates))))
      sample_data$groupvar <- as.Date(sample_data$groupvar)
      data <- sample_data %>%
        filter(val >= 0 & !is.na(val))
      fit <- ftmev(data, minyears = 5)
      expect_true("c" %in% names(fit))
      expect_true("w" %in% names(fit))
      expect_true("n" %in% names(fit))
      expect_true("maxima" %in% names(fit))
      expect_true("data" %in% names(fit))
      expect_true("years" %in% names(fit))
      expect_true("threshold" %in% names(fit))
      expect_true("x" %in% names(fit))
      expect_true("type" %in% names(fit))
      expect_true("minyears" %in% names(fit))
    })
  })
})
