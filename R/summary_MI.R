#' Calculate Summary Statistics for SSVS-MI Results
#'
#' Computes the average estimates, standard deviation, and 95% confidence intervals for coefficients
#' from an SSVS result object.
#'
#' @param x An SSVS result object or a compatible data frame containing model estimates.
#' @return A data frame with variables, average coefficients, standard deviation, and confidence intervals.
#' @examples
#' \donttest{
#' data(example_data)
#' outcome <- "yMCAR40"
#' predictors <- c("xMCAR40_1", "xMCAR40_2", "xMCAR40_3", "xMCAR40_4", "xMCAR40_5")
#' results <- SSVS_MI(data = example_data, y = outcome, x = predictors, imputations = 3, replications = 3)
#' summary_stats <- summary_MI(results, x = predictors)
#' print(summary_stats)
#' }
#' @export
summary_MI <- function(data, x, cf_min = 0.025, cf_max = 0.975) {
  assert_ssvs(data)

  data <- data %>%
    as.data.frame() %>%
    dplyr::mutate(Variables = x) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      avg.beta = mean(dplyr::c_across(dplyr::contains("Avg.Beta")), na.rm = TRUE),
      sd.beta = sd(dplyr::c_across(dplyr::contains("Avg.Beta")), na.rm = TRUE),
      min = quantile(dplyr::c_across(dplyr::contains("Avg.Beta")), probs = cf_min, na.rm = TRUE),
      max = quantile(dplyr::c_across(dplyr::contains("Avg.Beta")), probs = cf_max, na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(Variables, avg.beta, sd.beta, min, max)

  class(data) <- c("ssvs_summary", class(data))
  data
}
