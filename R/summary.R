#' SSVS summary function
#'
#' Function to summarize results from SSVS including marginal inclusion probabilities,
#' Bayesian model averaged parameter estimates, and
#' 95% highest posterior density credible intervals
#'
#'
#' @param object The result list from running the SSVS function
#' @param interval The desired probability for the credible interval, specified as a decimal
#' @param cutoff Minimum MIP cutoff where a predictor will be shown in the output, specified as a decimal
#' @param order The order that predictors will be shown in the output.
#' @param ... Ignored
#' Default is the order they are run in SSVS function
#' @examples
#' outcome <- "qsec"
#' predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
#' results <- SSVS(x = predictors, y = outcome, data = mtcars, plot = FALSE)
#' summary(results, interval=.9,order="MIP Descending" )
#' @return Returns a dataframe with results
#' @export
#'
#' @importFrom bayestestR ci
#'
#'



summary.ssvs <- function(object,interval=0.95,cutoff=0,order=c("As entered","MIP Descending"), ...){
  assert_ssvs(object)

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

  colnames(res) <- c('Variable', 'MIP', 'Avg Beta',paste0('Lower CI (',interval*100,'%)'),paste0('Upper CI (',interval*100,'%)'), 'Avg Nonzero Beta')

  res[,1] <- colnames(object$beta)
  res[,2] <- inc_prob[,1]
  res[,3] <- average.beta
  res[,4] <- lower.credibility
  res[,5] <- upper.credibility
  res[,6] <- average.nonzero.beta
  res <- as.data.frame(res)

  res[,2:6] <- apply(res[,2:6],2, function(x) as.numeric(x))


  if ((length(order)==1)&&(order=="MIP Descending")){
    res <- res[order(-res$MIP),]
  }


  res <- res[res$MIP>cutoff,]
  print.data.frame(res,right=F, row.names=F)
}
