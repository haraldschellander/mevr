# Create a mock data structure similar to the input for the ordinary_events function
set.seed(123)
mock_data <- list(
  data = data.frame(
    val = c(runif(50), rep(NA, 10), runif(40)),  # Simulate some missing values in the data
    groupvar = seq.POSIXt(Sys.time(), by = "10 min", length.out = 100)
  ),
  ts_res = 10,  # 10-minute time resolution
  fromto = data.frame(from = c(1, 51), to = c(50, 100))
)

# Test 1: Basic functionality with valid data and duration
test_that("ordinary_events calculates correct rolling sum and returns the maximum within each interval", {
  result <- ordinary_events(mock_data, duration = 30)
  
  expect_true(is.data.frame(result))  # Check if result is a data frame (or tibble)
  expect_equal(ncol(result), 2)  # Ensure result has two columns (v_date and val)
  expect_equal(nrow(result), 2)  # There are two from-to ranges, so we expect 2 rows
  expect_true(all(!is.na(result$val)))  # Ensure there are no NA values in val
})

# Test 2: Handling of NA values with na.rm = TRUE
test_that("ordinary_events removes NA values if na.rm = TRUE", {
  result <- ordinary_events(mock_data, duration = 30, na.rm = TRUE)
  
  # Since NA values are removed, result should still calculate the rolling sum correctly
  expect_true(all(!is.na(result$val)))
})

# # Test 3: Handling of NA values with na.rm = FALSE
# test_that("ordinary_events keeps NA values if na.rm = FALSE", {
#   result <- ordinary_events(mock_data, duration = 30, na.rm = FALSE)
#   
#   # Some rolling sums might result in NA, check if the function handles it
#   expect_true(any(is.na(result$val)))  # At least one NA should be present
# })

# Test 4: Handling of insufficient data for the rolling window
test_that("ordinary_events returns NULL when the data length is shorter than the duration window", {
  # Define a smaller dataset with fewer points than required by the rolling window
  small_data <- mock_data
  small_data$data <- small_data$data[1:10, ]  # Only 10 rows
  result <- ordinary_events(small_data, duration = 360)
  
  # Since no interval has enough data for the rolling window, we expect no results
  expect_true(is.null(result))
})

# # Test 5: Handling of empty or NULL data input
# test_that("ordinary_events handles empty or NULL data", {
#   empty_data <- mock_data
#   empty_data$data <- data.frame(val = numeric(0), groupvar = numeric(0))  # Empty data
#   
#   result <- ordinary_events(empty_data, duration = 30)
#   expect_equal(nrow(result), 0)  # No rows should be returned for empty data
#   
#   null_data <- list(data = NULL, ts_res = 10, fromto = data.frame(from = c(1), to = c(10)))
#   result <- ordinary_events(null_data, duration = 30)
#   expect_null(result)  # Should return NULL for completely missing data
# })

# Test 5: Handling of empty or NULL data input
test_that("should throw an error when data is empty", {
  empty_data <- mock_data
  empty_data$data <- data.frame(val = numeric(0), groupvar = numeric(0))  # Empty data
  expect_error(ordinary_events(empty_data, duration = 30), "data has no rows")
})

# Test 6: Check proper alignment and correct timestamp in result
test_that("ordinary_events returns correct timestamp for maximum rolling sum", {
  result <- ordinary_events(mock_data, duration = 30)
  
  # Check if the v_date in the result is a valid POSIXt type
  expect_true(inherits(result$v_date, "POSIXt"))
})


test_that("ordinary_events handles events shorter than duration correctly and preserves n", {
  # Setup mock high-resolution time-series data with a very short event (e.g., 20 minutes)
  mock_times <- seq.POSIXt(
    as.POSIXct("2020-01-01 00:00:00", tz = "UTC"),
    by = "10 min",
    length.out = 150
  )
  
  # Create a short rainfall event of 20 min (2 time steps of 10 min) and a longer one
  mock_vals <- rep(0, 150)
  mock_vals[10:11] <- c(1.5, 2.0)  # Short event: 20 minutes total duration
  mock_vals[50:80] <- runif(31, 0.5, 3.0) # Longer event: over 5 hours
  
  mock_data <- data.frame(
    groupvar = mock_times,
    val = mock_vals
  )
  
  # Step 1: Run event separation (with short duration tolerance)
  sep_res <- event_separation(
    mock_data,
    separation_period = 180, 
    time_resolution = 10, 
    ignore_event_duration = 10, # allow short events
    min_rain = 0.1
  )
  
  # Step 2: Extract ordinary events at a short duration (e.g., 10 minutes)
  events_short <- ordinary_events(sep_res, duration = 10)
  
  # Step 3: Extract ordinary events at a long duration (e.g., 120 minutes / 2 hours)
  # The short event (20 min) should NOT be dropped; its sum should be captured.
  events_long <- ordinary_events(sep_res, duration = 120)
  
  # Assertions
  # The number of detected storms should stay constant across different aggregation durations
  expect_equal(nrow(events_short), nrow(events_long))
  expect_equal(nrow(events_long), 2) # Both the short and long events must be present
  
  # Verify that the short event's aggregated value at long duration equals its total volume
  short_event_idx <- 1
  expected_short_sum <- sum(mock_vals[sep_res$fromto$from[1]:sep_res$fromto$to[1]])
  expect_equal(events_long$val[short_event_idx], expected_short_sum)
})