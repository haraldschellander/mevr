test_that("pp.weibull", {
  describe("pp.weibull function", {
    it("should throw an error if length of output differs from length of input", {
      data <- c(1, 2, 3)
      result <- pp.weibull(data)
      expect_equal(length(data), length(result))
    })
  })
})
