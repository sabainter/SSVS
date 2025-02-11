#' Perform SSVS for continuous and binary outcomes
#'
#' For continuous outcomes, a basic Gibbs sampler is used. For binary
#' outcomes, [`BoomSpikeSlab::logit.spike()`] is used.
#'
#' @param data The dataframe used to extract predictors and response values
#' @param y The response variable
#' @param x The set of predictor variables
#' @param continuous If `TRUE`, treat the response variable as continuous. If
#' `FALSE`, treat the response variable as binary.
#' @param inprob Prior inclusion probability value, which applies to all predictors.
#' The prior inclusion probability reflects the prior belief that each predictor
#' should be included in the model. A prior inclusion probability of .5 reflects
#' the belief that each predictor has an equal probability of being included or
#' excluded. Note that a value of .5 also implies a prior belief that the true model
#' contains half of the candidate predictors. The prior inclusion probability will
#' influence the magnitude of the marginal inclusion probabilities (MIPs), but the
#' relative pattern of MIPs is expected to remain fairly consistent, see Bainter et al.
#' (2020) for more information.
#' @param runs Total number of iterations (including burn-in). Results are based on
#' the Total - Burn-in iterations.
#' @param burn Number of burn-in iterations. Burn-in iterations are discarded
#' warmup iterations used to achieve MCMC convergence. You may increase the number
#' of burn-in iterations if you are having convergence issues.
#' @param a1 Prior parameter for Gamma(a,b) distribution on the precision (1/variance)
#' residual variance. Only used when `continuous = TRUE`.
#' @param b1 Prior parameter for Gamma(a,b) distribution on the precision (1/variance)
#' residual variance. Only used when `continuous = TRUE`.
#' @param prec.beta Prior precision (1/variance) for beta coefficients.
#' Only used when `continuous = TRUE`.
#' @param progress If `TRUE`, show progress of the model creation. When `continuous = TRUE`,
#' progress plots will be created for every 1000 iterations. When `continuous = FALSE`,
#' 10 progress messages will be printed.
#' Only used when `continuous = TRUE`.
#' @examples
#' \donttest{
#' # Example 1: continuous response variable
#' outcome <- "qsec"
#' predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
#' results <- ssvs(data = mtcars, x = predictors, y = outcome, progress = FALSE)
#'
#' # Example 2: binary response variable
#' library(AER)
#' data(Affairs)
#' Affairs$hadaffair[Affairs$affairs > 0] <- 1
#' Affairs$hadaffair[Affairs$affairs == 0] <- 0
#' outcome <- "hadaffair"
#' predictors <- c("gender", "age", "yearsmarried", "children", "religiousness",
#' "education", "occupation", "rating")
#' results <- ssvs(data = Affairs, x = predictors, y = outcome, continuous = FALSE, progress = FALSE)
#' }
#' @return An ssvs object that can be used in
#' [`summary()`][`summary.ssvs`] or [`plot()`][`plot.ssvs`].
#' @export
ssvs <- function(data, y, x, continuous = TRUE,
                 inprob = 0.5, runs = 20000, burn = 5000,
                 a1 = 0.01, b1 = 0.01, prec.beta = 0.1, progress = TRUE) {
  checkmate::assert_data_frame(data, min.rows = 1, min.cols = 2)
  checkmate::assert_character(x, any.missing = FALSE, min.len = 1)
  checkmate::assert_character(y, any.missing = FALSE, len = 1)
  checkmate::assert_subset(c(x, y), names(data))
  checkmate::assert_logical(continuous, len = 1, any.missing = FALSE)
  checkmate::assert_number(inprob, lower = 0, upper = 1)
  checkmate::assert_integerish(burn, lower = 1, len = 1, any.missing = FALSE)
  checkmate::assert_integerish(runs, lower = burn + 1, len = 1, any.missing = FALSE)
  checkmate::assert_number(a1, lower = 0)
  checkmate::assert_false(a1 == 0)
  checkmate::assert_number(b1, lower = 0)
  checkmate::assert_false(b1 == 0)
  checkmate::assert_number(prec.beta, lower = 0)
  checkmate::assert_false(prec.beta == 0)
  checkmate::assert_logical(progress, len = 1, any.missing = FALSE)

  if (continuous) {
    ssvs <- ssvs_continuous(
      data = data, y = y, x = x,
      inprob = inprob, runs = runs, burn = burn,
      a1 = a1, b1 = b1, prec.beta = prec.beta, progress = progress
    )
  } else {
    ssvs <- ssvs_binary(
      data = data, y = y, x = x,
      inprob = inprob, runs = runs, burn = burn, progress = progress
    )
  }
  #class(ssvs)<- sets the class of the ssvs output object to class "ssvs"
  class(ssvs) <- c("ssvs", class(ssvs))
  #sets the "response" attribute of ssvs object to y. Setting this attribute here
  #to be used for setting the title in the plot.ssvs
  attr(ssvs, "response") <- y
  ssvs
}

ssvs_continuous <- function(data, y, x, inprob, runs, burn, a1, b1, prec.beta, progress) {
  y <- data[, y]
  x <- data[, x]

  # error message for missing values
  if (sum(is.na(x)) + sum(is.na(y)) > 0) {
    stop("Missing values in selection")
  }

  # Added scaling inside function for X only
  x <- scale(x)

  p <- ncol(x)
  xp <- matrix(0, 25, p)
  xp[, 1] <- seq(-3, 3, length = 25)
  n <- length(y)
  np <- nrow(xp)

  # initial values:

  int <- mean(y)
  beta <- rep(0, p)
  alpha <- rep(0, p)
  delta <- rep(0, p)
  taue <- 1 / stats::var(y)

  # keep track of stuff:

  keep.beta <- matrix(0, runs, p)
  colnames(keep.beta) <- colnames(x)
  keep.int <- keep.taue <- rep(0, runs)
  keep.yp <- matrix(0, runs, np)

  # LET'S ROLL:
  for (i in 1:runs) {
    taue <- stats::rgamma(1, n / 2 + a1, sum((y - int - x %*% beta)^2) / 2 + b1)
    int <- stats::rnorm(1, mean(y - x %*% beta), 1 / sqrt(n * taue))

    # update alpha
    z <- x %*% diag(delta)
    V <- solve(taue * t(z) %*% z + prec.beta * diag(p))
    M <- taue * t(z) %*% (y - int)
    alpha <- V %*% M + t(chol(V)) %*% stats::rnorm(p)
    beta <- alpha * delta

    # update inclusion indicators:
    r <- y - int - x %*% beta
    for (j in 1:p) {
      r <- r + x[, j] * beta[j]
      log.p.in <- log(inprob) - 0.5 * taue * sum((r - x[, j] * alpha[j])^2)
      log.p.out <- log(1 - inprob) - 0.5 * taue * sum(r^2)
      diff <- log.p.in - log.p.out
      diff <- ifelse(diff > 10, 10, diff)
      p.in <- exp(diff) / (1 + exp(diff))
      delta[j] <- stats::rbinom(1, 1, p.in)
      beta[j] <- delta[j] * alpha[j]
      r <- r - x[, j] * beta[j]
    }

    # Make predictions:
    yp <- stats::rnorm(np, int + xp %*% beta, 1 / sqrt(taue))

    # Store the output:
    keep.beta[i, ] <- beta
    keep.int[i] <- int
    keep.taue[i] <- taue
    keep.yp[i, ] <- yp

    if ((i %% 1000 == 0) & (progress == TRUE)) {
      plot(beta, main = paste("Iteration", i))
      graphics::abline(0, 0)
    }
  }

  result <- list(
    beta = keep.beta[burn:runs, ],
    int = keep.int[burn:runs],
    taue = keep.taue[burn:runs],
    pred = keep.yp[burn:runs, ]
  )

  result
}

ssvs_binary <- function(data, y, x, inprob, runs, burn, progress) {
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
  if (progress) {
    ping <- runs / 10
  } else {
    ping <- 0
  }
  bssResults <- BoomSpikeSlab::logit.spike(formula = as.matrix(y) ~ as.matrix(x),
                                           niter = runs,
                                           prior = myPrior,
                                           ping = ping)
  bssResults[["beta"]] <- as.data.frame(bssResults[["beta"]][-c(1:burn),-1])

  colnames(bssResults[["beta"]]) <- colnames(x)

  bssResults
}
