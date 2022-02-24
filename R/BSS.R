#' BSS Function
#'
#' This function performs SSVS for binary outcomes, it is a wrapper for the
#' logit.spike() function from the BoomSpikeSlab package.
#'
#' @param x The set of predictor variables
#' @param y The binary response variable
#' @param data The dataframe used to extract predictors and response values
#' @param inprob Prior inclusion probability value, which applies to all predictors.
#' @param runs Total number of iterations (including burn-in). Results are based on
#' the Total - Burn-in iterations.
#' @param burn Number of burn-in iterations. Burn-in iterations are discarded
#' warmup iterations used to achieve MCMC convergence. You may increase the number
#' of burn-in iterations if you are having convergence issues.
#'
#' @return Returns a list
#' @export
#'
#' @importFrom  BoomSpikeSlab LogitZellnerPrior logit.spike


BSS <- function(x,y,data,inprob,runs=20000,burn=5000){

  # Automatically convert any two-level factors to binary variables
  for (i in 1:ncol(data[,x])){
    if (length(levels(data[,i]))==2){
      data[,i] <- as.numeric(data[,i]) - 1
      message("Two level factor converted to binary")
    }
  }

  x <- data[,x]
  y <- data[,y]

  # Scale inputs
  x <- scale(as.matrix(x))
  y <- (as.matrix(y))

  # Make a column of 1s for the design matrix
  intercept <- rep(1, nrow(x))

  # Create design matrix that includes the column of 1s, and the predictors
  designMatrix <- as.matrix(cbind(intercept, x))

  # Save the prior value to use
  myPrior <- BoomSpikeSlab::LogitZellnerPrior(predictors = designMatrix,
                               successes = y,
                               trials = NULL,
                               expected.model.size = (ncol(x)*inprob),
                               prior.inclusion.probabilities = NULL)




  ## logit.spike()
  bssResults <- BoomSpikeSlab::logit.spike(formula = as.matrix(y) ~
                                             as.matrix(x),
                                           niter = runs,
                                           prior = myPrior)
  bssResults[["beta"]] <- as.data.frame(bssResults[["beta"]][-c(1:burn),-1])

  colnames(bssResults[["beta"]]) <- colnames(x)

  class(bssResults) <- c("ssvs", class(bssResults))

  return(bssResults)

}


