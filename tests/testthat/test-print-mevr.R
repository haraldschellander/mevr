test_that("print should correctly print arguments for SMEV fit", {
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

test_that("print should correctly print arguments for MEVD fit", {
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

test_that("print should correctly print arguments for TMEV fit", {
  set.seed(123)
  sample_dates <- seq.Date(
    from = as.Date("2000-01-01"),
    to = as.Date("2006-01-01"),
    by = "day"
  )
  sample_data <- data.frame(
    groupvar = sample_dates,
    val = sample(rnorm(length(sample_dates)))
  )
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


test_that("print.mevr handles errors, different model types, and formatting options", {
  data(dailyrainfall)

  # 1. Error handling: object must be of class 'mevr'
  expect_error(
    print.mevr(list(type = "SMEV", c = 1, w = 1, n = 1)),
    "x must be object of class 'mevr'"
  )

  # 2. Print SMEV fit (single parameter case: length(w) == 1)
  fit_smev <- fsmev(dailyrainfall)
  output_smev <- capture.output(print(fit_smev))
  expect_true(any(grepl("Type: SMEV", output_smev)))
  expect_true(any(grepl("Scale C:", output_smev)))
  expect_true(any(grepl("Mean number of wet events n:", output_smev)))

  # 3. Print MEVD fit (multi-year case: length(w) > 1)
  fit_mev <- fmev(dailyrainfall[1:1000, ], method = "pwm")
  output_mev <- capture.output(print(fit_mev, digits = 4))
  expect_true(any(grepl("Type: MEVD", output_mev)))
  expect_true(any(grepl("Years:", output_mev)))
  expect_true(any(grepl("Wet events n:", output_mev)))

  # 4. Print fit with left-censoring parameter displayed
  fit_lc <- fsmev(dailyrainfall, left_cens = 0.8)
  output_lc <- capture.output(print(fit_lc))
  expect_true(any(grepl("Left-censoring quantile:", output_lc)))
})
