# Print method for object of class mevr

Print nicely formatted output of the fit to the MEVD and its variants

## Usage

``` r
# S3 method for class 'mevr'
print(x, digits = max(3, getOption("digits") - 3), ...)
```

## Arguments

- x:

  Object of class `mevr`, fitted with MEVD, SMEV or TMEV.

- digits:

  Number of digits.

- ...:

  Additional parameters.

## Value

A nicely formatted output of the fitting results.

## Examples

``` r
data(dailyrainfall)

# fit a simplified MEVD
fit <- fsmev(dailyrainfall)
print(fit)
#> MEVD fitting
#> 
#> Type: SMEV
#> Estimator: pwm
#> 
#> Parameters:
#> Scale C:
#> [1]  89.59
#> 
#> Shape w:
#> [1]  0.8643
#> 
#> Mean number of wet events n:
#> [1]  179.2
#> 
#> Threshold:
#> [1]  0
```
