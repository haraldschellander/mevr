# Daily rainfall data

A dataset containing daily rainfall intended to be used with the package
`mevr`

## Usage

``` r
data(dailyrainfall)
```

## Format

The dataset contains real world daily rainfall observations from a
station in the northern Alps. The series contains values from 1971 to
1985 and are assumed to be Weibull distributed. This data series is
intended to be used as is as input data for the package `mevr` to fit
the metastatistical extreme value distribution and its variants with
different estimation methods.

The dataset is a dataframe with two columns, dates and val:

- dates:

  Days of class `Date` in the format YYYY-MM-DD

- val:

  Rainfall observations corresponding to the date in the row. The value
  is the 24 hour sum from the morning hours of day-1 to the morning
  hours of day.

## Examples

``` r
## Load example data
data(dailyrainfall)

## explore dataset
head(dailyrainfall)
#>        dates val
#> 1 1971-01-02   9
#> 2 1971-01-03  25
#> 3 1971-01-20   2
#> 4 1971-01-22  13
#> 5 1971-01-27  13
#> 6 1971-02-01 101
hist(dailyrainfall$val)

plot(dailyrainfall$val, type = "o")
```
