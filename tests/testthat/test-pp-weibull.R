test_that("pp-weibull should throw an error if length of output differs from length of input", {
  data <- c(1, 2, 3)
  result <- pp.weibull(data)
  expect_equal(length(data), length(result))
})
