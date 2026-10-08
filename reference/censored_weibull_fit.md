# Fit Weibull distribution to censored data

Finds the optimal left-censoring threshold(s) at which the data series
should be censored to make sure that the observations in the tail are
likely sampled from a Weibull distribution

## Usage

``` r
censored_weibull_fit(x, thresholds, warn)
```

## Arguments

- x:

  A tibble which is most commonly a result of function
  [`weibull_tail_test`](https://haraldschellander.github.io/mevr/reference/weibull_tail_test.md).

- thresholds:

  A numeric or vector of quantiles which shal be tested as optimal
  threshold for left-censoring.

- warn:

  If `TRUE` which is the default, warnings about censoring are given.

## Value

A tibble with the optimal threshold itself and the Weibull scale and
shape parameters obtained from the censored sample.

## Examples

``` r
data("dailyrainfall")
wbtest <- weibull_tail_test(dailyrainfall)
censored_weibull_fit(wbtest, 0.9)
#> # A tibble: 1 × 4
#>   optimal_threshold scale shape quantile
#>               <dbl> <dbl> <dbl>    <dbl>
#> 1               234  96.0 0.912      0.9
```
