#' Summarize results of an SSVS model
#'
#' Summarize results from SSVS including marginal inclusion probabilities,
#' Bayesian model averaged parameter estimates, and
#' 95% highest posterior density credible intervals. Estimates and
#' credible intervals are based on standardized X variables.
#'
#' @param object An SSVS result object obtained from [`ssvs()`]
#' @param interval The desired probability for the credible interval, specified as a decimal
#' @param threshold Minimum MIP threshold where a predictor will be shown in the output, specified as a decimal
#' @param ordered If `TRUE`, order the results based on MIP (in descending order)
#' @param ... Ignored
#' @examples
#' \donttest{
#' outcome <- "qsec"
#' predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
#' results <- ssvs(data = mtcars, x = predictors, y = outcome, progress = FALSE)
#' summary(results, interval = 0.9, ordered = TRUE)
#' }
#' @return A dataframe with results
#' @export
summary.ssvs <- function(object, interval = 0.89, threshold = 0,
                         ordered = FALSE, ...){
  assert_ssvs(object)
  checkmate::assert_number(interval, lower = 0, upper = 1)
  checkmate::assert_number(threshold, lower = 0, upper = 1)
  checkmate::assert_logical(ordered, len = 1, any.missing = FALSE)

  # Get MIP for each variable
  inc_prob <- as.data.frame(round(apply(object$beta!=0,2,mean),4))

  # Get all post-burnin beta values
  temp.beta.frame <- as.data.frame(object[["beta"]])
  # Get average betas and upper and lower credibility
  average.beta <- NULL
  lower.credibility <- NULL
  upper.credibility <- NULL
  for (m in names(temp.beta.frame)){
    average.beta[m] <- round(mean(temp.beta.frame[,m]),4)
    # 95% credibility interval lower
    lower.credibility[m] <- round(bayestestR::ci(temp.beta.frame[,m], method = "HDI",ci = interval)[[2]],4)
    # 95% credibility interval upper
    upper.credibility[m] <- round(bayestestR::ci(temp.beta.frame[,m], method = "HDI",ci = interval)[[3]],4)
  }

  # Save the average non-zero betas
  temp.beta.frame.nonzero <- temp.beta.frame
  is.na(temp.beta.frame.nonzero) <- temp.beta.frame.nonzero==0

  # Loop
  average.nonzero.beta <- NULL
  for (m in names(temp.beta.frame.nonzero)){
    # Obtain mean
    average.nonzero.beta[m] <- round(mean(temp.beta.frame.nonzero[,m], na.rm = TRUE),4)
  }


  res <- matrix(nrow=ncol(object$beta),ncol=6)

  colnames(res) <- c('Variable', 'MIP', 'Avg Beta','Avg Nonzero Beta',
                     paste0('Lower CI (', interval * 100, '%)'),
                     paste0('Upper CI (', interval * 100, '%)'))

  res[, 1] <- colnames(object$beta)
  res[, 2] <- inc_prob[, 1]
  res[, 3] <- average.beta
  res[, 4] <- average.nonzero.beta
  res[, 5] <- lower.credibility
  res[, 6] <- upper.credibility
  res <- as.data.frame(res)

  res[, 2:6] <- apply(res[, 2:6], 2, function(x) as.numeric(x))


  if (ordered){
    res <- res[order(-res$MIP), ]
  }


  res <- res[res$MIP > threshold, ]
  #set the class of the res object to class "ssvs_summary"
  class(res) <- c("ssvs_summary", class(res))
  res
}

#' Print the summary of an SSVS model
#' @export
#' @keywords internal
print.ssvs_summary <- function(x, ...) {
  print.data.frame(x, right = FALSE, row.names = FALSE)
}
