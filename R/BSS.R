#' BSS Function
#'
#' @param y The response variable
#' @param x The set of predictor variables
#' @param priorValue test
#' @param runs test
#' @param burn test
#'
#' @return Returns a list
#' @export
#'
#' @importFrom  BoomSpikeSlab LogitZellnerPrior logit.spike


BSS <- function(x,y,priorValue,runs,burn){
  # Scale inputs
  x <- scale(as.matrix(x))
  y <- scale(as.matrix(y))

  # Make a column of 1s for the design matrix
  intercept <- rep(1, nrow(x))

  # Create design matrix that includes the column of 1s, and the predictors
  designMatrix <- as.matrix(cbind(intercept, x))

  # Save the prior value to use
  myPrior <- BoomSpikeSlab::LogitZellnerPrior(predictors = designMatrix,
                               successes = y,
                               trials = NULL,
                               expected.model.size = (ncol(x)*priorValue),
                               prior.inclusion.probabilities = NULL)




  ## logit.spike()
  bssResults <- BoomSpikeSlab::logit.spike(formula = as.matrix(y) ~
                                             as.matrix(x),
                                           niter = runs,
                                           prior = myPrior)
  bssResults[["beta"]] <- as.data.frame(bssResults[["beta"]][-c(1:burn),-1])

  colnames(bssResults[["beta"]]) <- colnames(x)

  return(bssResults)

}


