test_that("weibull-tail-test should throw an error if data is not a data.frame", {
  expect_error(fsmev(list(1, 2)), "data must be of class 'data.frame'")
})

test_that("weibull-tail-test should throw an error if date column is not of class 'Date'", {
  data <- data.frame(groupvar = c("2024-01-01", "2025-01-01"), val = c(10, 20))
  expect_error(fsmev(data), "date column must be of class 'Date' or 'POSIXct'")
})

test_that("weibull-tail-test should throw an error if data values are not of class 'numeric'", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(10, "20")
  )
  expect_error(fsmev(data), "data values must be of class 'numeric'")
})

test_that("weibull-tail-test should throw an error if data contains negative values", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(-10, 20)
  )
  expect_error(fsmev(data), "data must not contain values < 0")
})

test_that("weibull-tail-test should throw a warning if data contains NA values", {
  data <- data.frame(
    groupvar = c(as.Date(c("2024-01-01", "2025-01-01"))),
    val = c(10, NA)
  )
  expect_warning(fsmev(data), "data contains 1 NA values which are ignored.")
})

test_that("weibull-tail-test should throw an error is cens_quant is not a single numeric", {
  date_seq <- seq(as.Date("2024-01-01"), as.Date("2025-01-01"), by = "day")
  val_seq <- rnorm(length(date_seq), 20, 5)
  data <- data.frame(dates = date_seq, val = val_seq)
  expect_error(
    weibull_tail_test(data, cens_quant = c(0.8, 0.9)),
    "cens_quant must be a single numeric"
  )
})

test_that("weibull-tail-test should correctly perform a weibull tail test for valid input", {
  data("dailyrainfall")
  result <- weibull_tail_test(dailyrainfall, R = 100)
  expect_true("is_rejected" %in% names(result))
  expect_true("scale" %in% names(result))
  expect_true("shape" %in% names(result))
  expect_true("p_out" %in% names(result))
})

test_that("weibull_tail_test and censored_weibull_fit handle edge cases", {
  data(dailyrainfall)

  # Error checks
  expect_error(
    weibull_tail_test("not-a-df"),
    "data must be of class 'data.frame'"
  )
  expect_error(
    weibull_tail_test(dailyrainfall, cens_quant = c(0.8, 0.9)),
    "cens_quant must be a single numeric"
  )

  # Test fitting when all tails are rejected (threshold index out of bounds)
  mock_res <- tibble(
    is_rejected = c(TRUE, TRUE, TRUE),
    p_out = c(0.2, 0.3, 0.4),
    p_hi = c(0.1, 0.15, 0.2),
    p_lo = c(0.1, 0.15, 0.2),
    scale = c(1, 1, 1),
    shape = c(1, 1, 1),
    thresh = c(10, 20, 30),
    quant = c(0.5, 0.6, 0.7)
  )
  fit_cens <- censored_weibull_fit(
    mock_res,
    thresholds = c(0.5, 0.6, 0.7),
    warn = FALSE
  )
  expect_true(all(is.na(fit_cens$shape)))
})

test_that("weibull_tail_scan equals weibull_tail_test for each quantile", {
  data("dailyrainfall")
  d <- setNames(dailyrainfall, c("groupvar", "val"))
  q <- c(0.1, 0.5, 0.9)
  set.seed(42)
  scan <- weibull_tail_scan(d, cens_quants = q, R = 200)
  single <- do.call(rbind, lapply(q, function(x) {
    set.seed(42)
    weibull_tail_test(d, cens_quant = x, R = 200)
  }))
  expect_equal(nrow(scan), length(q))
  expect_equal(scan, single)
})

test_that("weibull_tail_test parameters equal the lm fit in Weibull coordinates", {
  data("dailyrainfall")
  d <- setNames(dailyrainfall, c("groupvar", "val"))
  res <- weibull_tail_test(d, cens_quant = 0.5, R = 50)
  bm_dates <- d |>
    dplyr::group_by(yr = format(.data$groupvar, "%Y")) |>
    dplyr::slice_max(.data$val) |>
    dplyr::pull(.data$groupvar)
  o <- order(d$val)
  x <- d$val[o]
  is_bm <- d$groupvar[o] %in% bm_dates
  N <- length(x)
  keep <- x > res$thresh & !is_bm
  X <- log(-log(1 - (seq_len(N) / (N + 1))[keep]))
  Y <- log(x[keep])
  cf <- stats::coef(stats::lm(Y ~ X))
  expect_equal(res$shape, 1 / unname(cf[2]))
  expect_equal(res$scale, exp(unname(cf[1])))
})

test_that("weibull_tail_scan outcome is stable across random seeds", {
  data("dailyrainfall")
  d <- setNames(dailyrainfall, c("groupvar", "val"))
  q <- seq(0.05, 0.95, 0.05)
  rej <- sapply(1:5, function(s) {
    set.seed(s)
    weibull_tail_scan(d, cens_quants = q, R = 500)$is_rejected
  })
  # with R independent synthetic samples the outcome must not depend on the seed
  expect_true(all(rej == rej[, 1]))
})

test_that("censored_weibull_fit warns by default if all tails are rejected", {
  mock_res <- tibble(
    is_rejected = TRUE,
    p_out = 0.3,
    p_hi = 0.15,
    p_lo = 0.15,
    scale = 1,
    shape = 1,
    thresh = 10,
    quant = 0.9
  )
  expect_warning(
    fit_cens <- censored_weibull_fit(mock_res, 0.9),
    "the assumption of Weibull tail is rejected"
  )
  expect_true(is.na(fit_cens$shape))
})
