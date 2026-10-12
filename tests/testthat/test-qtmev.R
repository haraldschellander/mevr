test_that("qtmev should throw an error if data argument is not of class 'data.frame'", {
  expect_error(qtmev(1, 1:3), "data must be of class 'data.frame'")
})
