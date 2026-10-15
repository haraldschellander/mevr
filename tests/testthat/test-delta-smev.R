# Tests for the delta method of the SMEV:
#   smev.vcov(), smev.delta.se(), rl.smev.delta(), rp.smev.delta(),
#   ci.smev(method = "delta") and return.levels.mev(method = "delta")

# --- helpers -----------------------------------------------------------------
# mevr-like SMEV object with a user supplied covariance matrix of (c, w)
fake_smev <- function(cc = 90, w = 0.85, n = 180, varcov = NULL) {
  structure(
    list(
      c = cc,
      w = w,
      n = n,
      varcov = varcov,
      left_cens = 0,
      censor = FALSE,
      type = "SMEV"
    ),
    class = "mevr"
  )
}

# mevr-like SMEV object fitted to a sample x of ordinary events
make_smev <- function(x, method = "mle", left_cens = 0, n = 100) {
  fit <- fit.mev(x, method, left_cens)
  structure(
    list(
      c = fit$c,
      w = fit$w,
      n = n,
      data = x,
      left_cens = left_cens,
      censor = FALSE,
      method = method,
      type = "SMEV"
    ),
    class = "mevr"
  )
}

vc_c_w <- function(vcc, vww, vcw = 0) {
  matrix(c(vcc, vcw, vcw, vww), 2, dimnames = list(c("c", "w"), c("c", "w")))
}

# central finite difference of f(par) w.r.t. par[i] (relative step)
fd <- function(f, par, i, h = 1e-5) {
  up <- par
  dn <- par
  d <- h * par[i]
  up[i] <- up[i] + d
  dn[i] <- dn[i] - d
  (f(up) - f(dn)) / (2 * d)
}

# --- smev.vcov ---------------------------------------------------------------
test_that("smev.vcov uses and orders a supplied covariance matrix", {
  vc <- vc_c_w(4, 0.01, 0.5)
  expect_equal(smev.vcov(fake_smev(varcov = vc)), vc)

  # reordered dimnames are matched by name
  vc_wc <- matrix(
    c(0.01, 0.5, 0.5, 4),
    2,
    dimnames = list(c("w", "c"), c("w", "c"))
  )
  expect_equal(smev.vcov(fake_smev(varcov = vc_wc)), vc)

  # unnamed 2x2 matrix is assumed to be ordered (c, w)
  vc_un <- matrix(c(4, 0.5, 0.5, 0.01), 2)
  expect_equal(smev.vcov(fake_smev(varcov = vc_un)), vc)

  # additional parameters are dropped
  vc3 <- matrix(
    c(4, 0.5, 0, 0.5, 0.01, 0, 0, 0, 9),
    3,
    dimnames = list(c("c", "w", "n"), c("c", "w", "n"))
  )
  expect_equal(smev.vcov(fake_smev(varcov = vc3)), vc)
})

test_that("smev.vcov reuses varcov of a fit with sd = TRUE", {
  data(dailyrainfall)
  set.seed(1)
  fit <- fsmev(dailyrainfall, sd = TRUE, R = 20)
  expect_equal(smev.vcov(fit), fit$varcov)
})

test_that("smev.vcov refuses censor = TRUE without varcov", {
  x <- fake_smev()
  x$censor <- TRUE
  expect_error(smev.vcov(x), "censor = TRUE")
})

test_that("smev.vcov is symmetric positive definite and identical for vector and data frame input", {
  data(dailyrainfall)
  fit_df <- fsmev(dailyrainfall, method = "mle")
  fit_vec <- fsmev(dailyrainfall$val, method = "mle") # x$years is NULL here
  vc <- smev.vcov(fit_df)
  expect_equal(dim(vc), c(2, 2))
  expect_equal(dimnames(vc), list(c("c", "w"), c("c", "w")))
  expect_true(isSymmetric(unname(vc), tol = 1e-6))
  expect_true(all(eigen(vc, symmetric = TRUE)$values > 0))
  expect_equal(smev.vcov(fit_vec), vc)
})

test_that("smev.vcov matches the asymptotic Weibull MLE covariance (complete sample)", {
  set.seed(10)
  N <- 5000
  x <- stats::rweibull(N, shape = 0.8, scale = 10)
  fit <- make_smev(x, "mle")
  cc <- fit$c
  w <- fit$w
  # Cohen (1965): Var(c) = 1.1087 c^2 / (N w^2), Var(w) = 0.6079 w^2 / N,
  #               Cov(c, w) = 0.2570 c / N
  k <- pi^2 / 6
  g <- 1 - 0.5772156649015329
  expected <- matrix(
    c((k + g^2) * cc^2 / w^2, g * cc, g * cc, w^2) / (k * N),
    2
  )
  expect_equal(unname(smev.vcov(fit)), expected, tolerance = 0.1)
})

test_that("left-censoring reduces the information on the Weibull shape", {
  set.seed(11)
  x <- stats::rweibull(2000, shape = 0.8, scale = 10)
  f0 <- make_smev(x, "mle", left_cens = 0)
  f1 <- make_smev(x, "mle", left_cens = 0.75)
  v0 <- smev.vcov(f0)
  v1 <- smev.vcov(f1)
  expect_gt(v1["w", "w"] / f1$w^2, v0["w", "w"] / f0$w^2)
  expect_gt(v1["c", "c"] / f1$c^2, v0["c", "c"] / f0$c^2)
})

test_that("smev.vcov of a left-censored fit agrees with the Monte Carlo covariance of the MLE", {
  skip_on_cran()
  set.seed(12)
  N <- 1000
  lc <- 0.5
  est <- t(replicate(200, {
    f <- fit.mev(stats::rweibull(N, shape = 0.8, scale = 10), "mle", lc)
    c(f$c, f$w)
  }))
  sd_mc <- apply(est, 2, stats::sd)

  fit <- make_smev(stats::rweibull(N, shape = 0.8, scale = 10), "mle", lc)
  sd_obs <- sqrt(diag(smev.vcov(fit)))
  expect_equal(unname(sd_obs), unname(sd_mc), tolerance = 0.3)
})

# --- smev.delta.se -----------------------------------------------------------
test_that("smev.delta.se combines the gradient and covariance correctly", {
  vc <- matrix(c(4, 1, 1, 9), 2)
  expect_equal(smev.delta.se(1, 0, 0, vc, 0), 2)
  expect_equal(smev.delta.se(0, 1, 0, vc, 0), 3)
  # 1*4 + 2*(1*2*1) + 4*9 + 3^2 * 1
  expect_equal(smev.delta.se(1, 2, 3, vc, 1), sqrt(53))
  # vectorised
  expect_equal(
    smev.delta.se(c(1, 0), c(0, 1), c(0, 0), vc, 0),
    c(2, 3)
  )
})

test_that("smev.delta.se returns 0 instead of NaN for a negative quadratic form", {
  vc_indef <- matrix(c(1, 2, 2, 1), 2)
  expect_equal(smev.delta.se(1, -1, 0, vc_indef, 0), 0)
})

# --- rl.smev.delta -----------------------------------------------------------
test_that("rl.smev.delta returns the estimated return levels and consistent limits", {
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle")
  rp <- c(2, 5, 10, 20, 50, 100, 200)
  d <- rl.smev.delta(fit, rp)

  expect_named(d, c("rl", "se", "lower", "upper"))
  expect_equal(d$rl, rlmev(rp, fit$w, fit$c, fit$n))
  expect_true(all(lengths(d) == length(rp)))
  expect_true(all(d$se > 0))
  expect_true(all(d$lower > 0))
  expect_true(all(d$lower < d$rl & d$rl < d$upper))
  expect_true(all(diff(d$rl) > 0))
  expect_true(all(diff(d$lower) > 0))
  expect_true(all(diff(d$upper) > 0))
})

test_that("rl.smev.delta is exact for n = 1 (closed form)", {
  cc <- 90
  w <- 0.85
  vcc <- 25
  vww <- 0.004
  fit <- fake_smev(cc, w, n = 1, varcov = vc_c_w(vcc, vww))
  rp <- c(2, 10, 100)
  d <- rl.smev.delta(fit, rp, alpha = 0.05)

  # n = 1: x_T = c * log(T)^(1/w)
  expect_equal(d$rl, cc * log(rp)^(1 / w))
  se_log <- sqrt(vcc / cc^2 + vww * log(log(rp))^2 / w^4)
  expect_equal(d$se, d$rl * se_log)
  z <- qnorm(0.975)
  expect_equal(d$lower, d$rl * exp(-z * se_log))
  expect_equal(d$upper, d$rl * exp(z * se_log))
})

test_that("rl.smev.delta gradient agrees with finite differences (incl. n)", {
  cc <- 90
  w <- 0.85
  n <- 180
  vc <- vc_c_w(25, 0.004, 0.3)
  var_n <- 4
  rp <- c(2, 10, 50, 200)
  d <- rl.smev.delta(fake_smev(cc, w, n, vc), rp, var_n = var_n)

  f <- function(p) log(qmev(1 - 1 / rp, w = p[2], c = p[1], n = p[3]))
  par <- c(cc, w, n)
  g <- cbind(fd(f, par, 1), fd(f, par, 2), fd(f, par, 3))
  se_log <- sqrt(
    g[, 1]^2 *
      vc[1, 1] +
      2 * g[, 1] * g[, 2] * vc[1, 2] +
      g[, 2]^2 * vc[2, 2] +
      g[, 3]^2 * var_n
  )
  expect_equal(d$se / d$rl, se_log, tolerance = 1e-5)
})

test_that("rl.smev.delta intervals are symmetric on the log scale and respond to alpha, var_n and zero variance", {
  fit <- fake_smev(varcov = vc_c_w(25, 0.004, 0.3))
  rp <- c(2, 10, 100)
  d <- rl.smev.delta(fit, rp, alpha = 0.1)
  expect_equal(log(d$upper / d$rl), -log(d$lower / d$rl))

  wide <- rl.smev.delta(fit, rp, alpha = 0.01)
  narrow <- rl.smev.delta(fit, rp, alpha = 0.2)
  expect_true(all(wide$upper - wide$lower > narrow$upper - narrow$lower))

  withn <- rl.smev.delta(fit, rp, alpha = 0.1, var_n = 100)
  expect_true(all(withn$se > d$se))

  zero <- rl.smev.delta(fake_smev(varcov = vc_c_w(0, 0)), rp)
  expect_equal(zero$se, rep(0, 3))
  expect_equal(zero$lower, zero$rl)
  expect_equal(zero$upper, zero$rl)
})

test_that("rl.smev.delta rejects objects that are not SMEV fits", {
  data(dailyrainfall)
  expect_error(rl.smev.delta(fmev(dailyrainfall), c(2, 10)), "type SMEV")
  expect_error(rl.smev.delta(list(c = 1, w = 1, n = 1), 10), "type SMEV")
})

# --- rp.smev.delta -----------------------------------------------------------
test_that("rp.smev.delta inverts the return levels", {
  fit <- fake_smev(varcov = vc_c_w(25, 0.004, 0.3))
  rp <- c(2, 10, 100)
  lv <- rlmev(rp, fit$w, fit$c, fit$n)
  d <- rp.smev.delta(fit, lv)
  expect_named(d, c("level", "rp", "lower", "upper"))
  expect_equal(d$level, lv)
  expect_equal(d$rp, rp)
  expect_equal(d$rp, 1 / (1 - pmev(lv, fit$w, fit$c, fit$n)))
  expect_true(all(d$lower < d$rp & d$rp < d$upper))
})

test_that("rp.smev.delta is exact for n = 1 (closed form)", {
  cc <- 90
  w <- 0.85
  vcc <- 25
  vww <- 0.004
  fit <- fake_smev(cc, w, n = 1, varcov = vc_c_w(vcc, vww))
  lv <- c(50, 100, 200)
  d <- rp.smev.delta(fit, lv, alpha = 0.05)

  # n = 1: T = exp((x / c)^w), log T = (x / c)^w
  s <- (lv / cc)^w
  expect_equal(d$rp, exp(s))
  se_log <- sqrt((w * s / cc)^2 * vcc + (s * log(lv / cc))^2 * vww)
  z <- qnorm(0.975)
  expect_equal(d$lower, exp(s) * exp(-z * se_log))
  expect_equal(d$upper, exp(s) * exp(z * se_log))
})

test_that("rp.smev.delta gradient agrees with finite differences (incl. n)", {
  cc <- 90
  w <- 0.85
  n <- 180
  vc <- vc_c_w(25, 0.004, 0.3)
  var_n <- 4
  lv <- c(600, 900, 1200, 1500)
  d <- rp.smev.delta(fake_smev(cc, w, n, vc), lv, var_n = var_n)

  f <- function(p) log(1 / (1 - pmev(lv, w = p[2], c = p[1], n = p[3])))
  par <- c(cc, w, n)
  g <- cbind(fd(f, par, 1), fd(f, par, 2), fd(f, par, 3))
  se_log <- sqrt(
    g[, 1]^2 *
      vc[1, 1] +
      2 * g[, 1] * g[, 2] * vc[1, 2] +
      g[, 2]^2 * vc[2, 2] +
      g[, 3]^2 * var_n
  )
  expect_equal(log(d$upper / d$rp) / qnorm(0.975), se_log, tolerance = 1e-5)
})

test_that("rp.smev.delta is monotone in the level and validates its input", {
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle")
  lv <- seq(300, 1500, length.out = 15)
  d <- rp.smev.delta(fit, lv)
  expect_true(all(d$rp > 1))
  expect_true(all(diff(d$rp) > 0))
  expect_true(all(d$lower < d$rp & d$rp < d$upper))

  expect_error(rp.smev.delta(fit, c(100, 0)), "levels must be > 0")
  expect_error(rp.smev.delta(fit, -5), "levels must be > 0")
  expect_error(rp.smev.delta(fmev(dailyrainfall), 100), "type SMEV")
})

# --- ci.smev(method = "delta") ---------------------------------------------
test_that("ci.smev with method = 'delta' returns the layout of the bootstrap", {
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle")
  rp <- c(2, 10, 50)
  out <- ci.smev(fit, method = "delta", alpha = 0.1, return.periods = rp)

  expect_true(is.matrix(out))
  expect_equal(dim(out), c(3, 3))
  expect_equal(rownames(out), c("2-year", "10-year", "50-year"))
  expect_equal(colnames(out), c("5%", "Estimate", "95%"))
  expect_equal(unname(out[, "Estimate"]), rlmev(rp, fit$w, fit$c, fit$n))
  expect_true(all(out[, 1] < out[, 2] & out[, 2] < out[, 3]))

  d <- rl.smev.delta(fit, rp, alpha = 0.1)
  expect_equal(unname(out[, 1]), d$lower)
  expect_equal(unname(out[, 3]), d$upper)
})

test_that("ci.smev with method = 'delta' has the same dimnames as the bootstrap", {
  skip_on_cran()
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle")
  rp <- c(2, 10)
  set.seed(1)
  boot <- ci.smev(fit, method = "boot", alpha = 0.1, return.periods = rp, R = 4)
  delta <- ci.smev(fit, method = "delta", alpha = 0.1, return.periods = rp)
  expect_equal(dimnames(delta), dimnames(boot))
})

test_that("ci.smev validates method and distribution type", {
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle")
  expect_error(ci.smev(fit, method = "foo"), "should be one of")
  expect_error(ci.smev(fmev(dailyrainfall), method = "delta"), "type SMEV")
})

# --- return.levels.mev(method = "delta") -------------------------------------
test_that("return.levels.mev supports method = 'delta' for the SMEV", {
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle")
  rp <- c(2, 10, 50)
  res <- return.levels.mev(
    fit,
    return.periods = rp,
    ci = TRUE,
    alpha = 0.1,
    method = "delta"
  )
  expect_named(res, c("rl", "rp", "ci"))
  expect_equal(res$rp, rp)
  expect_equal(dim(res$ci), c(3, 3))
  expect_equal(unname(res$ci[, "Estimate"]), res$rl)
  expect_true(all(res$ci[, 1] < res$rl & res$rl < res$ci[, 3]))

  # without ci the method is irrelevant
  expect_equal(
    return.levels.mev(fit, return.periods = rp, method = "delta"),
    return.levels.mev(fit, return.periods = rp)
  )
  expect_error(
    return.levels.mev(fit, ci = TRUE, method = "foo"),
    "should be one of"
  )
})

test_that("return.levels.mev(method = 'delta') works with a left-censored SMEV fit", {
  data(dailyrainfall)
  fit <- fsmev(dailyrainfall, method = "mle", left_cens = 0.75)
  res <- return.levels.mev(
    fit,
    return.periods = c(2, 10, 50),
    ci = TRUE,
    method = "delta"
  )
  expect_true(all(is.finite(res$ci)))
  expect_true(all(res$ci[, 1] < res$ci[, 3]))
})

test_that("return.levels.mev(method = 'delta') is only available for the SMEV", {
  data(dailyrainfall)
  expect_error(
    return.levels.mev(fmev(dailyrainfall), ci = TRUE, method = "delta"),
    "only available for the SMEV"
  )
  skip_on_cran()
  fit <- ftmev(dailyrainfall, minyears = 5)
  expect_error(
    return.levels.mev(
      fit,
      return.periods = c(2, 10),
      ci = TRUE,
      method = "delta"
    ),
    "only available for the SMEV"
  )
})

# --- statistical calibration -------------------------------------------------
test_that("delta intervals have roughly nominal coverage for iid ordinary events", {
  skip_on_cran()
  set.seed(42)
  cc <- 10
  w <- 0.8
  n <- 100
  N <- 3000 # 30 'years' of 100 ordinary events
  Tt <- 20
  rl_true <- qmev(1 - 1 / Tt, w, cc, n)
  R <- 300
  hit_rl <- logical(R)
  hit_rp <- logical(R)
  for (i in seq_len(R)) {
    fit <- make_smev(stats::rweibull(N, shape = w, scale = cc), "mle", n = n)
    d <- rl.smev.delta(fit, Tt, alpha = 0.1)
    hit_rl[i] <- d$lower <= rl_true && rl_true <= d$upper
    r <- rp.smev.delta(fit, rl_true, alpha = 0.1)
    hit_rp[i] <- r$lower <= Tt && Tt <= r$upper
  }
  # nominal 0.90, Monte Carlo s.e. about 0.017
  expect_gt(mean(hit_rl), 0.82)
  expect_lt(mean(hit_rl), 0.97)
  expect_gt(mean(hit_rp), 0.82)
  expect_lt(mean(hit_rp), 0.97)
})
