#' Imputed affairs Dataset
#'
#' This dataset is a version of the `Affairs` dataset where random missing values
#' were introduced, and multiple imputation was performed using the `mice` package.
#'
#' @format A data frame with 3005 rows and 12 variables
#' @details
#' Random missingness was introduced into 10% of the values in the original `Affairs` dataset.
#' Multiple imputation was then performed using the `mice` package with the following parameters:
#' \itemize{
#'   \item 5 multiple imputations (`m = 5`).
#'   \item 50 iterations per imputation (`maxit = 50`).
#'   \item Seed set to 123 for reproducibility.
#' }
#' The dataset included here is the first completed dataset resulting from the multiple imputation process.
#'
#' @examples
#' \donttest{
#' data(imputed_affairs)
#' head(imputed_affairs)
#' }
#' @source Original dataset from `datasets::Affairs`, with missing values introduced and imputed.
"imputed_affairs"
