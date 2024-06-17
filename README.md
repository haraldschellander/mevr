
# R-package mevr

R-functions for Fitting the Metastatistical Extreme Value Distribution MEVD. 

The MEVD assumes daily rainfall extremes being block maxima over a finite and stochastically variable number of “ordinary events” which are defined as samples from the underlying distribution ([Marani & Ignaccolo, 2015](https://doi.org/10.1016/j.advwatres.2015.03.001), [Zorzetto et al., 2016](https://doi.org/10.1002/2016GL069445)).

The functions in this package can be used to fit the MEVD, its simplified sibling SMEV ([Schellander et al., 2019](https://doi.org/10.1029/2019EA000557), [Marra et al., 2019](https://doi.org/10.1016/j.advwatres.2019.04.002)) and the explicitly non-stationary approach TMEV ([Falkensteiner et al., 2023](https://doi.org/10.1016/j.wace.2023.100601)) to data series.

The R-package `mevr` was written during the development of the TMEV ([Falkensteiner et al., 2023](https://doi.org/10.1016/j.wace.2023.100601)).


## Installation
# The easiest way to get mevr is to install it from CRAN:
install.packages("mevr")

