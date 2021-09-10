#' SSVS Function
#'
#' @param y The response variable
#' @param x The set of predictor variables
#' @param runs test
#' @param burn test
#' @param update test
#' @param a1 test
#' @param b1 test
#' @param prec.beta test
#' @param inprob test
#'
#' @return Returns a list
#' @export
#'
#' @importFrom stats rgamma rnorm rbinom reorder var
#' @importFrom graphics abline


SSVS <- function(y,x,
                 runs=20000,burn=5000,update=1000,
                 a1=0.01,b1=0.01,prec.beta=0.1,inprob=0.5){

  # error message for missing values
  if (sum(is.na(x))+sum(is.na(y))>0){
    stop('Missing values in selection')
  }

  # Added scaling inside function
  x <- scale(x)
  y <- scale(y)

  p  <- ncol(x)
  xp     <- matrix(0,25,p)
  xp[,1] <- seq(-3,3,length=25)
  n  <- length(y)
  np <- nrow(xp)

  #initial values:

  int   <- mean(y)
  beta  <- rep(0,p)
  alpha <- rep(0,p)
  delta <- rep(0,p)
  taue  <- 1/var(y)

  #keep track of stuff:

  keep.beta           <- matrix(0,runs,p)
  colnames(keep.beta) <- colnames(x)
  keep.int<-keep.taue <- rep(0,runs)
  keep.yp             <- matrix(0,runs,np)

  #LET'S ROLL:
  for(i in 1:runs){

    taue  <- rgamma(1,n/2+a1,sum((y-int-x%*%beta)^2)/2+b1)
    int   <- rnorm(1,mean(y-x%*%beta),1/sqrt(n*taue))

    #update alpha
    z     <- x%*%diag(delta)
    V     <- solve(taue*t(z)%*%z+prec.beta*diag(p))
    M     <- taue*t(z)%*%(y-int)
    alpha <- V%*%M+t(chol(V))%*%rnorm(p)
    beta  <- alpha*delta

    #update inclusion indicators:
    r <- y-int-x%*%beta
    for(j in 1:p){
      r         <- r+x[,j]*beta[j]
      log.p.in  <- log(inprob)-0.5*taue*sum((r-x[,j]*alpha[j])^2)
      log.p.out <- log(1-inprob)-0.5*taue*sum(r^2)
      diff      <- log.p.in-log.p.out
      diff      <- ifelse(diff>10,10,diff)
      p.in      <- exp(diff)/(1+exp(diff))
      delta[j]  <- rbinom(1,1,p.in)
      beta[j]   <- delta[j]*alpha[j]
      r         <- r-x[,j]*beta[j]
    }

    #Make predictions:
    yp <- rnorm(np,int+xp%*%beta,1/sqrt(taue))

    #Store the output:
    keep.beta[i,] <- beta
    keep.int[i]   <- int
    keep.taue[i]  <- taue
    keep.yp[i,]   <- yp

    if(i%%update==0){
      plot(beta,main=paste("Iteration",i))
      graphics::abline(0,0)
    }
  }

  list(beta = keep.beta[burn:runs,],
       int  = keep.int[burn:runs],
       taue = keep.taue[burn:runs],
       pred = keep.yp[burn:runs,])}
