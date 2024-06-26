% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mevr.R
\name{return.levels.mev}
\alias{return.levels.mev}
\title{Return Levels for the MEVD/SMEV/TMEV extreme value distributions}
\usage{
return.levels.mev(
  x,
  return.periods = c(2, 10, 20, 30, 50, 75, 100, 150, 200),
  ci = FALSE,
  alpha = 0.05,
  method = "boot",
  R = 502,
  ncores = 2L
)
}
\arguments{
\item{x}{An object of class \code{mevr}, either fitted with the MEVD, SMEV or TMEV}

\item{return.periods}{A vector of return periods in years, excluding 1.}

\item{ci}{If \code{ci=TRUE}, confidence intervals are calculated depending on the type of distribution (only for MEVD or SMEV).}

\item{alpha}{Number between zero and one giving the \code{1 - alpha} confidence level. Defaults to \code{alpha=0.05}.}

\item{method}{Character string giving the method for confidence interval calculation. Option \code{method='boot'} employs a 
parametric bootstrap that simulates data from the fitted model, and then fits the chosen MEVD type to each simulated data set 
to obtain a sample of parameters or return levels (very slow).}

\item{R}{The number of bootstrap iterations.}

\item{ncores}{Number of cores used for parallel computing of confidence intervals. Defaults to 2.}
}
\value{
A list with return levels, chosen return periods and, if \code{ci=TRUE}, 
\code{alpha/2} and \code{1 - alpha/2} confidence intervals.
}
\description{
Calculate return levels for a MEVD, SMEV or TMEV extreme value distributions 
from an object of class \code{mevr}.
}
\details{
Note that bootstraping the confidence intervals is very slow.
}
\examples{
data(dailyrainfall)

fit <- fmev(dailyrainfall)
return.levels.mev(fit)
plot(fit)
 
}
