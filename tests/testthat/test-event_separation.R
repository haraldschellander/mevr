# Create mock data for testing purposes
set.seed(123)
mock_data <- data.frame(
  groupvar = seq.POSIXt(Sys.time(), by = "10 min", length.out = 100),
  val = c(rep(0, 10), runif(20, 0, 1), rep(0, 70)) # Some rain and dry periods
)

# Test 1: Basic functionality with standard separation_period and time_resolution
test_that("event_separation identifies events correctly based on separation and time resolution", {
  result <- event_separation(
    mock_data,
    separation_period = 360,
    time_resolution = 10,
    ignore_event_duration = 30,
    min_rain = 0.1
  )

  expect_true(is.list(result)) # Check if result is a list
  expect_true(is.data.frame(result$data)) # Ensure result$data is a data frame
  expect_true(is.data.frame(result$fromto)) # Ensure result$fromto is a data frame

  # Check that 'from' and 'to' indices are correctly calculated
  expect_true(all(result$fromto$from < result$fromto$to))
  expect_true(nrow(result$fromto) > 0) # Ensure that at least one event is detected
})

# Test 2: Handling of small datasets with no events
test_that("event_separation handles datasets with no rainfall events", {
  no_rain_data <- data.frame(
    groupvar = seq.POSIXt(Sys.time(), by = "10 min", length.out = 50),
    val = rep(0, 50) # No rainfall at all
  )

  result <- event_separation(
    no_rain_data,
    separation_period = 360,
    time_resolution = 10,
    ignore_event_duration = 30,
    min_rain = 0.1
  )

  # Expect no events to be detected
  expect_equal(nrow(result$fromto), 0)
  expect_equal(sum(result$data$is_event), 0) # No events should be marked in the is_event column
})

# Test 3: Handling of datasets with continuous rainfall above threshold
test_that("event_separation detects continuous rainfall as a single event", {
  continuous_rain_data <- data.frame(
    groupvar = seq.POSIXt(Sys.time(), by = "10 min", length.out = 100),
    val = rep(0.5, 100) # Continuous rain above min_rain threshold
  )

  result <- event_separation(
    continuous_rain_data,
    separation_period = 360,
    time_resolution = 10,
    ignore_event_duration = 30,
    min_rain = 0.1
  )

  # Expect only one continuous event
  expect_equal(nrow(result$fromto), 1)
  expect_equal(sum(result$data$is_event), 100) # All points should be marked as event
})

# Test 4: Handling of minimum rain threshold
test_that("event_separation correctly applies minimum rainfall threshold", {
  mixed_rain_data <- data.frame(
    groupvar = seq.POSIXt(Sys.time(), by = "10 min", length.out = 100),
    val = c(rep(0.05, 50), rep(0.2, 50)) # Half of the data below min_rain, half above
  )

  result <- event_separation(
    mixed_rain_data,
    separation_period = 360,
    time_resolution = 10,
    ignore_event_duration = 30,
    min_rain = 0.1
  )

  # Expect one event starting from the 51st index
  expect_equal(nrow(result$fromto), 1)
  expect_true(all(result$data$is_event[51:100] == 1)) # Events should only be marked for rainfall above 0.1
})

# Test 5: Handling of event separation with different time resolutions
test_that("event_separation works correctly with different time resolutions", {
  result_5min <- event_separation(
    mock_data,
    separation_period = 360,
    time_resolution = 5,
    ignore_event_duration = 30,
    min_rain = 0.1
  )
  result_30min <- event_separation(
    mock_data,
    separation_period = 360,
    time_resolution = 30,
    ignore_event_duration = 30,
    min_rain = 0.1
  )

  expect_true(nrow(result_5min$fromto) > 0) # Events should be detected with 5-minute resolution
  expect_true(nrow(result_30min$fromto) > 0) # Events should be detected with 30-minute resolution
  expect_true(nrow(result_5min$fromto) >= nrow(result_30min$fromto)) # More events with finer resolution
})

# Test 6: Handling of ignore_event_duration
test_that("event_separation ignores events shorter than ignore_event_duration", {
  short_events_data <- data.frame(
    groupvar = seq.POSIXt(Sys.time(), by = "10 min", length.out = 50),
    val = c(rep(0, 20), 0.5, rep(0, 29)) # One very short event
  )

  result <- event_separation(
    short_events_data,
    separation_period = 360,
    time_resolution = 10,
    ignore_event_duration = 30,
    min_rain = 0.1
  )

  # No events should be detected due to ignore_event_duration being larger than the event length
  expect_equal(nrow(result$fromto), 0)
})
