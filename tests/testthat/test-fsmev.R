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
  set.seed(1)
  expect_no_warning(
    result <- fsmev(
      dailyrainfall,
      censor = TRUE,
      censor_opts = list(
        thresholds = c(0.1, 0.5, 0.8),
        mon = 1,
        nrtrials = 1,
        R = 100
      )
    )
  )
  expect_true("c" %in% names(result))
  expect_true("w" %in% names(result))
  expect_true("n" %in% names(result))
  expect_false(result$rejected)
  expect_true(result$opt_quant %in% c(0.1, 0.5, 0.8))
  expect_false(is.na(result$c))
  expect_false(is.na(result$w))
})

test_that("fsmev falls back to an uncensored fit if the Weibull tail is rejected", {
  data("dailyrainfall")
  opts <- list(thresholds = c(0.1, 0.5, 0.9), mon = 1, nrtrials = 1, R = 100)
  # dailyrainfall: the Weibull tail is rejected at the highest quantile 0.9,
  # so no censoring threshold is left
  set.seed(1)
  expect_warning(
    expect_warning(
      result <- fsmev(dailyrainfall, censor = TRUE, censor_opts = opts),
      "the assumption of Weibull tail is rejected"
    ),
    "fitting uncensored SMEV"
  )
  expect_true(result$rejected)
  expect_true(all(c("opt_quant", "opt_thresh") %in% names(result)))
  expect_true(is.na(result$opt_quant))
  expect_true(is.na(result$opt_thresh))
  expect_equal(
    unname(result$params[c("c", "w")]),
    unname(fsmev(dailyrainfall)$params[c("c", "w")])
  )

  set.seed(1)
  expect_no_warning(
    fsmev(dailyrainfall, censor = TRUE, censor_opts = opts, warn = FALSE)
  )
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

test_that("fsmev with censor = TRUE returns the censoring quantile, also with sd = TRUE", {
  data("dailyrainfall")
  opts <- list(thresholds = c(0.1, 0.5, 0.8), mon = 1, nrtrials = 1, R = 100)
  set.seed(1)
  fit <- fsmev(dailyrainfall, censor = TRUE, censor_opts = opts, warn = FALSE)
  set.seed(1)
  fit_sd <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = opts,
    warn = FALSE,
    sd = TRUE,
    R = 50
  )
  for (f in list(fit, fit_sd)) {
    expect_false(f$rejected)
    expect_true(f$opt_quant %in% opts$thresholds)
    d <- setNames(dailyrainfall, c("groupvar", "val"))
    expect_equal(
      f$opt_thresh,
      as.numeric(quantile(d$val[d$val > 0], f$opt_quant))
    )
  }
  expect_equal(fit_sd$opt_quant, fit$opt_quant)
  expect_equal(fit_sd$c, fit$c)
  expect_equal(fit_sd$w, fit$w)
})

test_that("fsmev bootstrap with censor = TRUE refits the censored estimator", {
  data("dailyrainfall")
  d <- setNames(dailyrainfall, c("groupvar", "val"))
  opts <- list(thresholds = c(0.1, 0.5, 0.8), mon = 1, nrtrials = 1, R = 100)
  set.seed(1)
  fit <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = opts,
    warn = FALSE,
    sd = TRUE,
    R = 100
  )
  # the estimator used in the bootstrap reproduces the censored fit
  cf <- tail_ls_fit(tail_prep(d[d$val > 0, ]), fit$opt_quant)
  expect_equal(fit$c, cf$scale)
  expect_equal(fit$w, cf$shape)

  # and the bootstrap is the one of the censored fit, not of the uncensored
  set.seed(2)
  boot_cens <- smev.boot(d[d$val > 0, ], R = 100, censor_quant = fit$opt_quant)
  set.seed(2)
  boot_unc <- smev.boot(d[d$val > 0, ], R = 100)
  expect_true(all(is.finite(boot_cens$std) & boot_cens$std > 0))
  expect_false(isTRUE(all.equal(boot_cens$std, boot_unc$std)))
  expect_equal(dim(fit$varcov), c(2, 2))
})

test_that("print and plot of censored fsmev fits show and handle the censoring quantile", {
  data("dailyrainfall")
  set.seed(1)
  fit <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.8), R = 100),
    warn = FALSE
  )
  expect_output(print(fit), "Censoring quantile")

  set.seed(1)
  fit_rej <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.9), R = 100),
    warn = FALSE
  )
  expect_true(fit_rej$rejected)
  out <- capture.output(print(fit_rej))
  expect_false(any(grepl("Censoring quantile", out)))

  pdf(NULL)
  on.exit(dev.off())
  expect_no_error(plot(fit_rej))
})

test_that("plot works for fsmev fits of a numeric vector", {
  data("dailyrainfall")
  fit <- fsmev(dailyrainfall[[2]])
  set.seed(1)
  fit_c <- fsmev(
    dailyrainfall[[2]],
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.8), R = 100),
    warn = FALSE
  )
  set.seed(1)
  fit_rej <- fsmev(
    dailyrainfall[[2]],
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.9), R = 100),
    warn = FALSE
  )
  pdf(NULL)
  on.exit(dev.off())
  for (f in list(fit, fit_c, fit_rej)) {
    for (tp in c("all", "rl", "qq", "pp", "hist")) {
      expect_no_error(plot(f, type = tp))
    }
  }
})

test_that("print and plot name the estimator of censored fsmev fits", {
  data("dailyrainfall")
  expect_output(print(fsmev(dailyrainfall)), "Estimator: pwm")
  set.seed(1)
  fit <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.8), R = 100),
    warn = FALSE
  )
  expect_output(print(fit), "Estimator: ls \\(left-censored\\)")
  expect_equal(estimator_label(fit), "ls (left-censored)")
  set.seed(1)
  fit_rej <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.9), R = 100),
    warn = FALSE
  )
  expect_equal(estimator_label(fit_rej), "pwm")
})

test_that("bootstrap return level CIs of censored fsmev fits refit censored", {
  data("dailyrainfall")
  set.seed(1)
  fit <- fsmev(
    dailyrainfall,
    censor = TRUE,
    censor_opts = list(thresholds = c(0.1, 0.5, 0.8), R = 100),
    warn = FALSE
  )
  expect_equal(fit$censor_opts$mon, 1)
  rp <- c(10, 50)
  set.seed(1)
  ci_c <- ci.smev(fit, method = "boot", return.periods = rp, R = 30, ncores = 1)
  fit_unc <- fit
  fit_unc$censor <- FALSE
  set.seed(1)
  ci_u <- ci.smev(
    fit_unc,
    method = "boot",
    return.periods = rp,
    R = 30,
    ncores = 1
  )
  expect_equal(dim(ci_c), c(2, 3))
  expect_true(all(is.finite(ci_c)))
  expect_true(all(ci_c[, 1] <= ci_c[, 3]))
  expect_false(isTRUE(all.equal(ci_c[, c(1, 3)], ci_u[, c(1, 3)])))
})
