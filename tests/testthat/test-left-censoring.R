test_that("fit.mev without left-censoring is unchanged", {
  set.seed(1)
  x <- rweibull(500, shape = 0.7, scale = 8)
  xs <- sort(x)
  N <- length(xs)
  M0 <- mean(xs)
  M1 <- sum(xs * (N - seq_len(N))) / (N * (N - 1))
  fit <- fit.mev(x, "pwm")
  expect_equal(fit$c, M0 / gamma(log(M0 / M1) / log(2)))
  expect_equal(fit$w, log(2) / log(M0 / (2 * M1)))
  expect_equal(fit.mev(x, "pwm", left_cens = 0), fit)
})

test_that("left-censored estimators recover the Weibull parameters", {
  set.seed(2)
  x <- rweibull(20000, shape = 0.6, scale = 0.9)
  for (m in c("pwm", "mle", "ls")) {
    for (q in c(0.5, 0.9)) {
      fit <- fit.mev(x, m, left_cens = q)
      expect_equal(fit$w, 0.6, tolerance = 0.05)
      expect_equal(fit$c, 0.9, tolerance = 0.1)
    }
  }
})

test_that("left-censored estimators do not depend on the censored values", {
  set.seed(3)
  x <- sort(rweibull(1000, shape = 0.8, scale = 2))
  y <- x
  y[1:900] <- x[1:900] / 10 # change the magnitudes below the censoring point
  for (m in c("pwm", "mle", "ls")) {
    expect_equal(fit.mev(x, m, left_cens = 0.9), fit.mev(y, m, left_cens = 0.9))
    expect_false(isTRUE(all.equal(
      suppressWarnings(fit.mev(x, m)),
      suppressWarnings(fit.mev(y, m))
    )))
  }
})

test_that("left-censored least squares equals the regression in Weibull coordinates", {
  set.seed(4)
  x <- sort(rweibull(1000, shape = 0.8, scale = 2))
  idx <- 901:1000
  mod <- lm(log(x[idx]) ~ log(-log(1 - idx / 1001)))
  fit <- fit.mev(x, "ls", left_cens = 0.9)
  expect_equal(fit$c, unname(exp(coef(mod)[1])))
  expect_equal(fit$w, unname(1 / coef(mod)[2]))
})

test_that("fsmev and fmev accept a fixed left-censoring quantile", {
  data("dailyrainfall")
  fit0 <- fsmev(dailyrainfall)
  fit1 <- fsmev(dailyrainfall, left_cens = 0.75)
  expect_equal(fit1$left_cens, 0.75)
  expect_equal(fit0$left_cens, 0)
  expect_equal(fit1$n, fit0$n) # n counts all ordinary events
  expect_false(isTRUE(all.equal(fit1$w, fit0$w)))
  expect_equal(fit1$w, fit.mev(fit0$data$val, "pwm", left_cens = 0.75)$w)

  fity <- fmev(dailyrainfall, left_cens = 0.5)
  expect_equal(length(fity$w), length(fity$n))
  expect_true(all(is.finite(fity$w)) && all(is.finite(fity$c)))

  expect_error(fsmev(dailyrainfall, left_cens = 1), "left_cens must be")
  expect_error(fsmev(dailyrainfall, left_cens = -0.1), "left_cens must be")
  expect_error(fmev(dailyrainfall, left_cens = c(0.1, 0.2)), "left_cens must be")
  expect_error(
    fsmev(dailyrainfall, left_cens = 0.9, censor = TRUE),
    "not both"
  )
})

test_that("ordinary_events keeps events aligned when the series contains NA", {
  t0 <- as.POSIXct("2020-06-01 00:00", tz = "UTC")
  v <- rep(0, 400)
  v[201:206] <- c(1, 3, 9, 4, 2, 1)
  d <- data.frame(groupvar = t0 + 600 * (0:399), val = v)
  ref <- ordinary_events(event_separation(d), duration = 10)
  expect_equal(ref$val, 9)

  d$val[50:59] <- NA # missing values long before the storm
  res <- ordinary_events(event_separation(d), duration = 10)
  expect_equal(res$val, 9)
  expect_equal(res$v_date, ref$v_date)
  expect_equal(ordinary_events(event_separation(d), duration = 30)$val, 16)
})
