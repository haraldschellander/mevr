# TMEV prediction

Takes a `mevr` object where the TMEV has been fitted to rainfall data
and calculates `bamlss` predictions for the distributional parameters
and the model terms. Basically a wrapper to the corresponding function
`predict.bamlss`

## Usage

``` r
# S3 method for class 'mevr'
predict(object, newdata, term, ...)
```

## Arguments

- object:

  Object of class `mevr`, fitted with the TMEV.

- newdata:

  A data frame with the model covariates (year, yday) at which
  predictions are required. Note that depending on argument term, only
  covariates that are needed by the corresponding model terms need to be
  supplied. If not supplied, predictions are made on the data supplied
  by the fitted object `x`.

- term:

  Character of the model terms for which predictions shall be
  calculated. Can only be `"year"` or `"yday"`. If not specified,
  predictions for all terms are calculated.

- ...:

  Arguments passed to prediction functions that are part of a
  bamlss.family object, i.e., the objects has a \$predict() function
  that should be used instead.

## Value

A data.frame with the supplied covariables and the predicted parameters.

## Details

See also the details of
[`ftmev`](https://haraldschellander.github.io/mevr/reference/ftmev.md)
for an explanation of the model terms used to fit the temporal trend of
the Weibull parameters. The basis dimensions yday_ti_shape_k,
yday_ti_scale_k, year_ti_shape_k, year_ti_scale_k are taken from the
fitting process, i.e. the call to
[`ftmev`](https://haraldschellander.github.io/mevr/reference/ftmev.md).

## See also

[`ftmev`](https://haraldschellander.github.io/mevr/reference/ftmev.md),
[`predict.bamlss`](http://www.bamlss.org/reference/predict.bamlss.md)

## Examples

``` r
data(dailyrainfall)

# restrict for the sake of speed
idx <- which(as.POSIXlt(dailyrainfall$date)$year + 1900 < 1976)
data <- dailyrainfall[idx, ]

f <- ftmev(data, minyears = 5)
predict(f, term = "year")
#>   year c.pred.year w.pred.year
#> 1 1971    79.87684   0.8607488
#> 2 1972    83.21258   0.8772784
#> 3 1973    86.68762   0.8941253
#> 4 1974    90.30778   0.9112958
#> 5 1975    94.07913   0.9287961
```
