#' Perform SSVS on Multiply Imputed Datasets
#'
#' This function performs Stochastic Search Variable Selection (SSVS) analysis on multiply imputed datasets
#' for a given set of predictors and a response variable. It supports continuous response variables and calculates
#' aggregated results across multiple imputations and replications.
#'
#' @param data A dataframe containing the variables of interest, including an `.imp` column for imputation identifiers
#'   and an `r` column for replication identifiers.
#' @param y The response variable (character string).
#' @param x A vector of predictor variable names.
#' @param imputations The number of imputations to process (default is 25).
#' @param replications The number of replications per imputation (default is 500).
#' @param interval Confidence interval level for summary results (default is 0.9).
#' @param continuous Logical indicating if the response variable is continuous (default is TRUE).
#' @param progress Logical indicating whether to display progress (default is FALSE).
#'
#' @return An SSVS object containing aggregated results across imputations and replications, including mean
#'   inclusion probabilities and average beta coefficients for each predictor.
#' @examples
#' \donttest{
#' data(example_data.csv)
#' outcome <- "yMCAR40"
#' predictors <- c("xMCAR40_1", "xMCAR40_2", "xMCAR40_3", "xMCAR40_4", "xMCAR40_5")
#' results <- SSVS_MI(data = example_data, y = outcome, x = predictors)
#' }
#' @export
SSVS_MI <- function(data, y, x, imputations = 25, replications = 500,
                         interval = 0.9, continuous = TRUE, progress = FALSE) {
  checkmate::assert_data_frame(data, min.rows = 1)
  checkmate::assert_character(y, len = 1)
  checkmate::assert_character(x, min.len = 1)
  checkmate::assert_logical(continuous, len = 1)
  checkmate::assert_logical(progress, len = 1)

  final_results <- data.frame(Variables = x)
  all_data <- NULL

  for (i in 1:imputations) {
    for (r in 1:replications) {
      temp <- data[data$.imp == i & data$r == r, c(x, y)]
      results <- SSVS::ssvs(data = temp, x = x, y = y, continuous = continuous, progress = progress)
      summary_results <- summary(results, interval = interval, ordered = FALSE)
      final_results <- merge(final_results, summary_results[, c("MIP", "Avg Beta")], by = 0, all = TRUE, sort = FALSE)[-1]
      names(final_results)[names(final_results) == "MIP"] <- paste(r, "MIP")
      names(final_results)[names(final_results) == "Avg Beta"] <- paste(r, "Avg Beta")
    }
    all_data <- rbind(all_data, final_results)
  }

  avg_imp <- all_data %>%
    dplyr::group_by(Variables) %>%
    dplyr::summarise(across(everything(), mean, .names = "mean_{.col}"))

  class(avg_imp) <- c("ssvs", class(avg_imp))
  attr(avg_imp, "response") <- y

  avg_imp
}

