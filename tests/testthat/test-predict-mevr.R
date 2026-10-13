set.seed(123)
sample_dates <- seq.Date(
  from = as.Date("2000-01-01"),
  to = as.Date("2010-01-01"),
  by = "day"
)
sample_data <- data.frame(
  groupvar = sample_dates,
  val = sample(rnorm(length(sample_dates)))
)
sample_data$groupvar <- as.Date(sample_data$groupvar)
sample_data <- sample_data %>%
  filter(val >= 0 & !is.na(val))


test_that("predict-mevr should throw an error if type of fit is not 'tmev'", {
  fit <- fsmev(sample_data)
  expect_error(predict.mevr(fit), "fitted object must be of type 'tmev'")
})

test_that("predict-mevr should correctly predict TMEV parameters for valid input", {
  fit <- ftmev(sample_data, minyears = 8)
  result <- predict.mevr(fit)
  # Check if the result has the expected structure
  expect_true("year" %in% names(result))
  expect_true("yday" %in% names(result))
  expect_true("c.pred" %in% names(result))
  expect_true("w.pred" %in% names(result))
  # Add more assertions based on what you expect the output to be
})


test_that("predict and plot methods work for TMEV and SMEV", {
  data(dailyrainfall)
  small_df <- dailyrainfall[1:1500, ]

  fit_tmev <- ftmev(small_df, minyears = 3, verbose = FALSE)

  # Predictions for specific terms
  pred_yr <- predict(fit_tmev, term = "year")
  expect_true(is.data.frame(pred_yr))

  pred_yday <- predict(fit_tmev, term = "yday")
  expect_true(is.data.frame(pred_yday))

  # Plot methods execution
  fit_smev <- fsmev(small_df)
  expect_invisible(plot(fit_smev, type = "rl"))
  expect_invisible(plot(fit_smev, type = "hist"))
  expect_invisible(plot(fit_smev, type = "qq"))
  expect_invisible(plot(fit_smev, type = "pp"))
})
