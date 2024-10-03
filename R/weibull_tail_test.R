#' @importFrom stats coef lm qweibull
NULL

set_season <- function(datum, block_start) {
  yr <- as.POSIXlt(datum)$year + 1900
  mt <- as.POSIXlt(datum)$mon + 1
  ifelse(mt < block_start, yr - 1, yr)
}


#' Fit Weibull distribution to censored data
#'
#' Finds the optimal left-censoring threshold(s) at which 
#' the data series should be censored to make sure that the observations 
#' in the tail are likely sampled from a Weibull distribution
#' @param x A tibble which is most commonly a result of function 
#' \code{\link{weibull_tail_test}}. 
#' @param thresholds A numeric or vector of quantiles which shal be tested 
#' as optimal threshold for left-censoring.
#' @param warn If \code{TRUE} which is the default, warnings about censoring are given.
#'
#' @return A tibble with the optimal threshold itself and 
#' the Weibull scale and shape parameters obtained from the censored sample.
#' @export
#'
#' @examples
#' data("dailyrainfall")
#' wbtest <- weibull_tail_test(dailyrainfall)
#' censored_weibull_fit(wbtest, 0.9)
#' 
censored_weibull_fit <- function(x, thresholds, warn) {
  
  # no rejection of weibull tails at all quantiles
  if (length(which(x$is_rejected)) == 0) {
    i_thr <- 1
  } else {
    i_thr <- max(which(x$is_rejected)) + 1
    if (is.na(i_thr)) {
      i_thr <- 1
    }  
  }
  
  if (i_thr > length(thresholds)) {
    warning("the assumption of Weibull tail is rejected")
    i_thr <- NA
    optimal_thr <- 0.95
    scale_cens <- NA
    shape_cens <- NA
  } else {
    optimal_thr <- x$thresh[i_thr]
    scale_cens <- x$scale[i_thr]
    shape_cens <- x$shape[i_thr]
  }
  
  tibble(optimal_threshold = optimal_thr,
         scale = scale_cens,
         shape = shape_cens,
         quantile = thresholds[i_thr])
}



#' Weibull tail test
#' 
#' This functions provides a way to test if observed rainfall maxima from a data series are 
#' likely samples from a parent distribution with a Weibull tail. The concept and the 
#' code is based on the paper Marra F, W Amponsah, SM Papalexiou, 2023. Non-asymptotic Weibull tails 
#' explain the statistics of extreme daily precipitation. Adv. Water Resour., 173, 104388, 
#' https://doi.org/10.1016/j.advwatres.2023.104388. They also provide the corresponding Matlab code 
#' (https://zenodo.org/records/7234708).
#' 
#' Null-Hyothesis: block maxima are samples from a parent distribution with
#' Weibull tail (tail defined by a given left-censoring threshold). If the fraction 
#' of observed block maxima outside of the interval defined by 
#' p_test is larger than p_test the null hypothesis is rejected.
#'
#' @param data A data.frame
#' @param threshold A numeric that is used to define wet days as values > threshold. 
#' @param mon This month defines the block whose maxima 
#' will be tested. The block goes from month-YYYY-1 to month-YYYY.
#' @param cens_quant The quantile at which the tail test should be performed. 
#' Must be a single numeric.
#' @param p_test A numeric defining the 1 - p_test confidence band. This function 
#' tests the ratio of observed block maxima below p_test and above 1 - p_test. See details.   
#' @param R The number of synthetic samples. 
#'
#' @return A tibble with the test outcome and other useful results:
#'   \item{is_rejected}{ outcome of the test (TRUE means that the assumption of
#'   Weibull tails for the given left-censoring threshold is rejected).}   
#'   \item{p_out}{ fraction of block maxima outside of the Y = 1 - p_out confidence interval} 
#'   \item{p_hi}{ fraction of block maxima above the Y = 1 - p_out confidence interval} 
#'   \item{p_lo}{ fraction of block maxima below the Y = 1 - p_out confidence interval} 
#'   \item{scale}{ scale parameter of the Weibull distribution describing the non-censored samples}
#'   \item{shape}{ shape parameter of the Weibull distribution describing the non-censored samples}
#'   \item{quant}{ the quantile used as left-censoring threshold}
#' @export
#'
#' @examples
#' data("dailyrainfall")
#' weibull_tail_test(dailyrainfall)
#' 
#' # generate data
#' set.seed(123)
#' sample_dates <- seq.Date(from = as.Date("2000-01-01"), to = as.Date("2010-12-31"), by = 1)
#' sample_data <- data.frame(dates = sample_dates, val = sample(rnorm(length(sample_dates))))
#' d <- sample_data |>
#'   filter(val >= 0 & !is.na(val))
#' fit_uncensored <- fsmev(d)
#' 
#' # censor the data
#' thresholds <- c(seq(0.1, 0.9, 0.1), 0.95)
#' p_test <- 0.1
#' res <- lapply(thresholds, function(x) {
#'   weibull_tail_test(d, cens_quant = x, p_test = p_test, R = 200)
#' })
#' res <- do.call(rbind, res)
#' 
#' # find the optimal left-censoring threshold
#' cens <- censored_weibull_fit(res, thresholds)
#' cens$optimal_threshold
#' cens$quantile
#' 
#' # plot return levels censored vs uncensored
#' rp <- c(2:100)
#' rl_uncensored <- return.levels.mev(fit_uncensored, return.periods = rp)$rl 
#' rl_censored <- qmev(1 - 1/rp, cens$shape, cens$scale, fit_uncensored$n)
#' plot(rp, rl_uncensored, type = "l", log = "x", ylim = c(0, max(rl_censored, rl_uncensored)), 
#'      ylab = "return level", xlab = "return period (a)")
#' points(pp.weibull(fit_uncensored$maxima), sort(fit_uncensored$maxima))
#' lines(rp, rl_censored, type = "l", col = "red")
#' legend("bottomright", legend = c("uncensored", 
#'         paste0("censored at ", round(cens$optimal_threshold, 1), "mm")), 
#'         col = c("black", "red"), lty = c(1, 1))
#'
weibull_tail_test <- function(data, threshold = 0, mon = 1, cens_quant = 0.9, 
                              p_test = 0.1, R = 500) {
  
  if(!inherits(data, "data.frame"))
    stop("data must be of class 'data.frame'")
  
  colnames(data) <- c("groupvar", "val")
  
  if (!inherits(data$groupvar, c("Date", "POSIXct"))) 
    stop("date column must be of class 'Date' or 'POSIXct'")
  
  if (!inherits(data$val, "numeric"))
    stop("data values must be of class 'numeric'")
  
  if (length(which(data$val < 0)) > 0)
    stop("data must not contain values < 0")
  
  if (any(is.na(data$val))) {
    n <- nrow(data)
    data <- na.omit(data)
    nn <- nrow(data)
    warning(paste0("data contains ", n - nn, " NA values which are ignored."))
  }
  
  if (length(cens_quant) > 1) {
    stop("cens_quant must be a single numeric")
  }
  
  # only wet days
  data <- data |> 
    as_tibble() |> 
    dplyr::arrange(.data$val) |> # needed for ecdf
    dplyr::filter(.data$val >= threshold) |> 
    dplyr::mutate(block = set_season(.data$groupvar, mon),
           bm = FALSE)
  data$ecdf <- 1:nrow(data) / (nrow(data) + 1)
  
  # find block maxima
  bm_dates <- data |> 
    dplyr::group_by(.data$block) |> 
    dplyr::slice_max(order_by = .data$val) |> 
    dplyr::pull(.data$groupvar)
  data$bm[which(data$groupvar %in% bm_dates)] <- TRUE
  
  # censor sample
   thresh <- as.numeric(quantile(data$val, probs = cens_quant))
   cens_data <- data |> 
     dplyr::arrange(.data$val) |> 
     dplyr::filter(.data$val > thresh)
  
  # censor bm
  cens_bm <- cens_data |> 
    dplyr::filter(.data$bm == TRUE)
  
  # remove block maxima from censored data
  # because censored data are used for fitting
  # and we want to know if observed maxima 
  # could be samples from the censored data
  cens_data <- cens_data |> 
    dplyr::filter(!.data$groupvar %in% bm_dates)
  
  
  # weibull parameters for censored sample
  # parameter estimation (least square linear regression in
  # Weibull-transformed coordinates) 
  X <- log(log(1 / (1 - cens_data$ecdf)))                # Weibull-transformation for probabilities
  Y <- log(cens_data$val)                                # Weibull-transformation for samples
  model <- lm(Y ~ X)                                     # linear regression
  scale <- exp(coef(model)[1])                           # Weibull scale parameter
  shape <- 1/coef(model)[2]                              # Weibull shape parameter
  
  
  # tail test
  # R synthetic samples of M x n elements
  # with Weibull parameters from censored sample
  syn_sample <- apply(matrix(runif(nrow(data)), nrow = nrow(data), ncol = R), 2, function(x) {
    y <- stats::qweibull(x, shape, scale)
    sort(y)
  })
  
  # p_test confidence interval
  # Calculate fractions of block maxima
  # fraction of block maxima out of the (1 - p_test) ci
  istest <- which(data$bm == TRUE)
  p_lo <- mean(cens_bm$val < quantile(syn_sample[istest, ], probs = p_test / 2))
  p_hi <- mean(cens_bm$val > quantile(syn_sample[istest, ], probs = 1 - p_test / 2))
  p_out <- p_lo + p_hi
  
  # outcome of the test
  is_rejected <- p_out > p_test
  
  tibble(is_rejected = is_rejected,
       p_out = p_out,
       p_hi = p_hi,
       p_lo = p_lo,
       scale = scale,
       shape = shape,
       thresh = thresh,
       quant = cens_quant)
}

