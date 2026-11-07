# Return Levels for the MEVD/SMEV/TMEV extreme value distributions

Calculate return levels for a MEVD, SMEV or TMEV extreme value
distributions from an object of class `mevr`.

## Usage

``` r
return.levels.mev(
  x,
  return.periods = c(2, 10, 20, 30, 50, 75, 100, 150, 200),
  ci = FALSE,
  alpha = 0.05,
  method = "boot",
  R = 502,
  ncores = 2L
)
```

## Arguments

- x:

  An object of class `mevr`, either fitted with the MEVD, SMEV or TMEV

- return.periods:

  A vector of return periods in years, excluding 1.

- ci:

  If `ci=TRUE`, confidence intervals are calculated depending on the
  type of distribution (only for MEVD or SMEV).

- alpha:

  Number between zero and one giving the `1 - alpha` confidence level.
  Defaults to `alpha=0.05`.

- method:

  Character string giving the method for confidence interval
  calculation. Option `method='boot'` employs a parametric bootstrap
  that simulates data from the fitted model, and then fits the chosen
  MEVD type to each simulated data set to obtain a sample of parameters
  or return levels (very slow).

- R:

  The number of bootstrap iterations.

- ncores:

  Number of cores used for parallel computing of confidence intervals.
  Defaults to 2.

## Value

A list with return levels, chosen return periods and, if `ci=TRUE`,
`alpha/2` and `1 - alpha/2` confidence intervals.

## Details

Note that bootstraping the confidence intervals is very slow.

## Examples

``` r
data(dailyrainfall)

fit <- fmev(dailyrainfall)
return.levels.mev(fit)
#> $rl
#> [1]  648.3965  929.8449 1041.5999 1107.0636 1190.1504 1256.7824 1304.4884
#> [8] 1372.3864 1421.0530
#> 
#> $rp
#> [1]   2  10  20  30  50  75 100 150 200
#> 
plot(fit)

```
