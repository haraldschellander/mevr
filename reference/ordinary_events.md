# Identifies ordinary rainfall events by calculating the maximum within rainfall events defined with [`event_separation`](https://haraldschellander.github.io/mevr/reference/event_separation.md)

This function calculates the rolling sum of values in the provided data
over a specified duration and identifies the events with the highest sum
within the defined time intervals. It is useful for detecting
significant events based on aggregated values over time.

## Usage

``` r
ordinary_events(x, duration, na.rm = TRUE)
```

## Arguments

- x:

  A list containing at least the following elements (usually the output
  of function
  [`event_separation`](https://haraldschellander.github.io/mevr/reference/event_separation.md)):

  - \`data\`: A data frame or data table with at least two columns:
    \`val\` (the values to sum) and \`groupvar\` (timestamps or another
    grouping variable).

  - \`ts_res\`: The time resolution of the data in minutes (i.e., how
    many minutes each time step represents).

  - \`fromto\`: A data frame with two columns: \`from\` and \`to\`,
    representing the start and end indices of the time intervals to
    analyze.

- duration:

  Numeric. The duration in minutes for which maxima shall be calculated.

- na.rm:

  Logical. If `na.rm = TRUE` (default), missing values within an event
  are ignored in the rolling sum. If `na.rm = FALSE`, windows that
  contain missing values are not considered for the event maximum.

## Value

Returns a tibble with individual rainfall events that can be used as
input for functions
[`fsmev`](https://haraldschellander.github.io/mevr/reference/fsmev.md),
[`fmev`](https://haraldschellander.github.io/mevr/reference/fmev.md),
[`ftmev`](https://haraldschellander.github.io/mevr/reference/ftmev.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage
x <- list(
  data = data.frame(val = runif(100),
  groupvar = seq.POSIXt(Sys.time(),
                        by = "10 min",
                        length.out = 100)
                        ),
  ts_res = 10,
  fromto = data.frame(from = c(1, 51), to = c(50, 100))
)
duration <- 30
result <- ordinary_events(x, duration)
print(result)
} # }
```
