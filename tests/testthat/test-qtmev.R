test_that("qtmev", {
  describe("qtmev function", {
    it ("should throw an error if data argument is not of class 'data.frame'", {
      expect_error(qtmev(1, 1:3), "data must be of class 'data.frame'")
    })
  })
})
