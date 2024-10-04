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
