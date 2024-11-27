
# mevr

<!-- badges: start -->
<!-- [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) -->
[![CRAN status](https://www.r-pkg.org/badges/version/mevr)](https://CRAN.R-project.org/package=mevr)
![(https://img.shields.io/github/v/tag/haraldschellander/mevr)](https://img.shields.io/github/v/tag/haraldschellander/mevr?include_prereleases)
[![Coverage](https://img.shields.io/codecov/c/github/haraldschellander/mevr)](https://app.codecov.io/gh/haraldschellander/mevr)
<!-- badges: end -->

R-functions for Fitting the Metastatistical Extreme Value Distribution MEVD. 

The MEVD assumes daily rainfall extremes being block maxima over a finite and stochastically variable number of “ordinary events” which are defined as samples from the underlying distribution ([Marani & Ignaccolo, 2015](https://doi.org/10.1016/j.advwatres.2015.03.001), [Zorzetto et al., 2016](https://doi.org/10.1002/2016GL069445)).

The functions in this package can be used to fit the MEVD, its simplified sibling SMEV ([Schellander et al., 2019](https://doi.org/10.1029/2019EA000557), [Marra et al., 2019](https://doi.org/10.1016/j.advwatres.2019.04.002)) and the explicitly non-stationary approach TMEV ([Falkensteiner et al., 2023](https://doi.org/10.1016/j.wace.2023.100601)) to data series.

The package also includes functions for the preparation of rainfall timeseries to the analysis of sub-daily durations. In particular, a timeseries can be separated into independent events based on a defined dry spell duration. The separated series can the be analysed for  maxima within the events, which are defined as ordinary events of the sub-daily duration.

The R-package `mevr` was written during the development of the TMEV ([Falkensteiner et al., 2023](https://doi.org/10.1016/j.wace.2023.100601)). See also this [GitHub repository](https://github.com/Falke96/extreme_precipitation_austria) which contains the original code.


## Installation

The easiest way to get mevr is to install it from CRAN
```r 
install.packages("mevr")
```


## Development version
To install the development version from GitHub

```r
# install.packages("pak")
pak::pak("haraldschellander/mevr")
```
