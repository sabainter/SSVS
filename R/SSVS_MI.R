#' Perform SSVS on Multiply Imputed Datasets
#'
#' This function performs Stochastic Search Variable Selection (SSVS) analysis on multiply imputed datasets
#' for a given set of predictors and a response variable. It supports continuous response variables and calculates
#' aggregated results across multiple imputations and replications.
#'
#' @param data A dataframe containing the variables of interest, including an `.imp` column for imputation identifiers.
#' @param y The response variable (character string).
#' @param x A vector of predictor variable names.
#' @param imp The imputation variable.
#' @param imputations The number of imputations to process (default is 5).
#' @param interval Confidence interval level for summary results (default is 0.9).
#' @param continuous Logical indicating if the response variable is continuous (default is TRUE).
#' @param progress Logical indicating whether to display progress (default is FALSE).
#'
#' @return An SSVS object containing aggregated results across imputations, including mean
#'   inclusion probabilities and average beta coefficients for each predictor.
#' @examples
#' \donttest{
#' data(imputed_mtcars)
#' outcome <- 'qsec'
#' predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt', 'vs', 'am', 'gear', 'carb','mpg')
#' imputation <- '.imp'
#' results <- SSVS_MI(data = imputed_mtcars, y = outcome, x = predictors, imp = imputation)
#' }
#' @export
ssvs_mi <- function(data, y, x, imp, imputations = 5,
                         interval = 0.9, continuous = TRUE, progress = FALSE) {
  checkmate::assert_data_frame(data, min.rows = 1)
  checkmate::assert_character(y, len = 1)
  checkmate::assert_character(x, min.len = 1)
  checkmate::assert_character(imp, min.len = 1)
  checkmate::assert_logical(continuous, len = 1)
  checkmate::assert_logical(progress, len = 1)

  final_results <- data.frame(Variables = x)

  for (i in 1:imputations) {
      data <- data %>%
        dplyr::filter(imp==i)
      temp <- data[, c(x, y)]
      results <- SSVS::ssvs(data = temp, x = x, y = y, continuous = continuous, progress = progress)
      summary_results <- summary(results, interval = interval, ordered = FALSE)
      final_results <- merge(final_results, summary_results[, c('MIP', 'Avg Beta', 'Avg Nonzero Beta')], by = 0, all = TRUE, sort = FALSE) [-1]
      names(final_results)[names(final_results) == "MIP"] <- paste(r, "MIP")
      names(final_results)[names(final_results) == "Avg Beta"] <- paste(r, "Avg Beta")
      names(final_results)[names(final_results) == 'Avg Nonzero Beta'] <- paste(r,'Avg Nonzero Beta')
  }

  class(final_results) <- c("ssvs", class(final_results))
  attr(final_results, "response") <- y

  final_results
}

