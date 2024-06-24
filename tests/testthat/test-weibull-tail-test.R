test_that("weibull_tail_test", {
  describe("weibull_tail_test function", {
    
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
    
    it("should correctly perform a weibull tail test for valid input", {
      data("dailyrainfall")
      result <- weibull_tail_test(dailyrainfall, R = 100)
      expect_true("is_rejected" %in% names(result))
      expect_true("scale" %in% names(result))
      expect_true("shape" %in% names(result))
      expect_true("p_out" %in% names(result))
    })
    
  })
})
