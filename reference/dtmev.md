# The non-stationary Metastatistical Extreme Value Distribution

Quantile function for the TMEV distribution with a Weibull parent
distribution.

## Usage

``` r
dtmev(x, data)

ptmev(q, data)

qtmev(p, data)
```

## Arguments

- x, q:

  Numeric vector or single value of probabilities for `dtmev`.

- data:

  A data frame with at least columns `c`, `w` and `year`. Can be taken
  from the output of the fitted TMEV object, i.e. `x$data` (see
  [`ftmev`](https://haraldschellander.github.io/mevr/reference/ftmev.md)).

- p:

  Numeric vector or single value of probabilities for `qtmev`.

## Value

`dtmev` gives the density function, `ptmev` gives the distribution
function, and `qtmev` gives the quantile function of the TMEV.

## Functions

- `ptmev()`: distribution quantile function

- `qtmev()`: distribution quantile function

## Examples

``` r
data(dailyrainfall)
fit <- ftmev(dailyrainfall)
rp <- pp.weibull(fit$maxima)
rl <- qtmev(1 - 1 / rp, fit$data)
plot(rp, sort(fit$maxima), main = "TMEV", ylab = "return level", xlab = "return period (years)")
lines(rp, rl, type = "l")


```
