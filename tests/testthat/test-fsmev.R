test_that("fsmev should throw an error if data is not a data.frame", {
  expect_error(
    fsmev(list(1, 2)),
    "data must be of class 'data.frame' or 'numeric'"
  )
})

test_that("fsmev should throw an error if date column is not of class 'Date' or 'POSIXct'", {
  data <- data.frame(groupvar = c("2024-01-01", "2025-01-01"), val = c(10, 20))
  expect_error(fsmev(data), "date column must be of class 'Date' or 'POSIXct'")
})

test_that("fsmev should throw an error if data values are not of class 'numeric'", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(10, "20")
  )
  expect_error(fsmev(data), "data values must be of class 'numeric'")
})

test_that("fsmev should throw an error if data contains negative values", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(-10, 20)
  )
  expect_error(fsmev(data), "data must not contain values < 0")
})

test_that("fsmev should throw a warning if data contains NA values", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(10, NA)
  )
  expect_warning(fsmev(data), "data contains 1 NA values")
})

test_that("fsmev should correctly calculate SMEV parameters for valid input", {
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

test_that("fsmev should correctly calculate SMEV parameters for method 'mle'", {
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

test_that("fsmev should correctly calculate SMEV parameters for method 'ls'", {
  # Setup a mock dataset
  set.seed(123)
  sample_dates <- seq.Date(
    from = as.Date("2000-01-01"),
    to = as.Date("2001-01-01"),
    by = "day"
  )
  sample_data <- data.frame(
    groupvar = sample_dates,
    val = sample(rnorm(length(sample_dates)))
  )
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

test_that("fsmev should correctly calculate standard errors for method 'pwm'", {
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

test_that("fsmev should correctly calculate standard errors for method 'mle'", {
  # Setup a mock dataset
  set.seed(123)
  sample_dates <- seq.Date(
    from = as.Date("2000-01-01"),
    to = as.Date("2001-01-01"),
    by = "day"
  )
  sample_data <- data.frame(
    groupvar = sample_dates,
    val = sample(rnorm(length(sample_dates)))
  )
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

test_that("fsmev should correctly calculate standard errors for method 'ls'", {
  # Setup a mock dataset
  set.seed(123)
  sample_dates <- seq.Date(
    from = as.Date("2000-01-01"),
    to = as.Date("2001-01-01"),
    by = "day"
  )
  sample_data <- data.frame(
    groupvar = sample_dates,
    val = sample(rnorm(length(sample_dates)))
  )
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

test_that("fsmev should throw an error if method of standard error calculation is not 'boot'", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(10, 20)
  )
  expect_error(
    fsmev(data, sd = TRUE, sd.method = "ana"),
    "only method 'boot' is allowed for calculation of standard errors"
  )
})

test_that("fsmev should correctly calculate SMEV parameters for censored input", {
  data("dailyrainfall")
  result <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = list(
      thresholds = c(0.1, 0.5, 0.9),
      mon = 1,
      nrtrials = 1,
      R = 100
    )
  )
  expect_true("c" %in% names(result))
  expect_true("w" %in% names(result))
  expect_true("n" %in% names(result))
  #expect_true("method" == "censored lsreg")
})

test_that("fsmev handles numeric vector input and input validation errors", {
  set.seed(42)
  vec_data <- rnorm(400, mean = 2, sd = 1)
  vec_data[vec_data < 0] <- 0

  # Vector input branch (vec = TRUE)
  fit_vec <- fsmev(vec_data, threshold = 0.1, method = "pwm")
  expect_s3_class(fit_vec, "mevr")
  expect_equal(fit_vec$type, "SMEV")

  # Error handling: invalid data class
  expect_error(
    fsmev("not-data"),
    "data must be of class 'data.frame' or 'numeric'"
  )

  # Error handling: negative values
  expect_error(fsmev(c(-1, 2, 3)), "data must not contain values < 0")

  # Warning on NA values
  df_na <- data.frame(
    dates = seq.Date(as.Date("2020-01-01"), by = "day", length.out = 10),
    val = c(1, 2, NA, 4, 5, 6, 7, 8, 9, 10)
  )
  expect_warning(fsmev(df_na), "data contains 1 NA values which are ignored.")
})
