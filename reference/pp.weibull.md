# Weibull plotting position

Calculates the Weibull plotting position for the given maxima

## Usage

``` r
pp.weibull(x)
```

## Arguments

- x:

  Numeric vector of block maxima

## Value

A numeric vector of Weibull plotting positions corresponding to the
given maxima `x`

## Examples

``` r
data(dailyrainfall)
fit <- fsmev(dailyrainfall)
rp <- pp.weibull(fit$maxima)
rl <- return.levels.mev(fit, return.periods = rp)
plot(rp, sort(fit$maxima), xlab = "Return period (years)", ylab = "Return level", main = fit$type)
lines(rp, rl$rl)
```
