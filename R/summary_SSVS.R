#' SSVS summary function
#'
#' @param ssvs.results The result list from running the SSVS function
#' @return Returns a dataframe with results
#' @export
#'
#' @importFrom bayestestR ci
#'



summary_SSVS <- function(ssvs.results){
  # Get MIP for each variable
  inc_prob <- as.data.frame(round(apply(ssvs.results$beta!=0,2,mean),4))

  # Get all post-burnin beta values
  temp.beta.frame <- as.data.frame(ssvs.results[["beta"]])
  # Get average betas and upper and lower credibility
  average.beta <- NULL
  lower.credibility <- NULL
  upper.credibility <- NULL
  for (m in names(temp.beta.frame)){
    average.beta[m] <- round(mean(temp.beta.frame[,m]),4)
    # 95% credibility interval lower
    lower.credibility[m] <- round(bayestestR::ci(temp.beta.frame[,m], method = "HDI",ci = .95)[[2]],4)
    # 95% credibility interval upper
    upper.credibility[m] <- round(bayestestR::ci(temp.beta.frame[,m], method = "HDI",ci = .95)[[3]],4)
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


  res <- matrix(nrow=ncol(ssvs.results$beta),ncol=6)

  colnames(res) <- c('Variable','MIP','Average Beta','Beta Low CI','Beta High CI', 'Average nonzero Beta')

  res[,1] <- colnames(ssvs.results$beta)
  res[,2] <- inc_prob[,1]
  res[,3] <- average.beta
  res[,4] <- lower.credibility
  res[,5] <- upper.credibility
  res[,6] <- average.nonzero.beta

  res <- as.data.frame(res)

  print(res, row.names=F)

}
