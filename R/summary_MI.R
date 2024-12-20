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
#' results <- ssvs_imputed(data = example_data, y = outcome, x = predictors)
#' summary_stats <- ssvs_summary(results)
#' print(summary_stats)
#' }
#' @export
summary_MI <- function(data, x, cf_min = 0.025, cf_max = 0.975) {
  checkmate::assert_ssvs(x,min.rows=1)

  data <- data %>%
    as.data.frame() %>%
    dplyr::mutate(Variables = x) %>%
    rowwise() %>%
    dplyr::mutate(
      avg.beta = mean(c_across(dplyr::contains("Avg.Beta")), na.rm = TRUE),
      sd.beta = sd(c_across(dplyr::contains("Avg.Beta")), na.rm = TRUE),
      min = quantile(c_across(dplyr::contains("Avg.Beta")), probs = cf_min, na.rm = TRUE),
      max = quantile(c_across(dplyr::contains("Avg.Beta")), probs = cf_max, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    dplyr::select(Variables, avg.beta, sd.beta, min, max)

  class(data) <- c("ssvs_summary", class(data))
  data
}
