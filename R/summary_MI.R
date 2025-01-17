#' Calculate Summary Statistics for SSVS-MI Results
#'
#' Computes summary statistics (average, minimum, and maximum) for beta coefficients, MIP and
#' average nonzero beta coefficients from an SSVS result object.
#'
#' @param x An SSVS result object or a compatible data frame containing model estimates.
#' @return A data frame with variables, average, minimum, and maximum for beta, MIP and nonzero beta
#' @examples
#' \donttest{
#' data(imputed_mtcars)
#' outcome <- 'qsec'
#' predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt', 'vs', 'am', 'gear', 'carb','mpg')
#' imputation <- '.imp'
#' results <- ssvs_mi(data = imputed_mtcars, y = outcome, x = predictors, imp = imputation)
#' summary_MI <- summary.mi(results)
#' print(summary_MI)
#' }
#' @export
summary.mi <- function(data) {
  assert_ssvs(data)

  data <- data %>%
    as.data.frame() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      avg.beta = mean(dplyr::c_across(dplyr::contains("Avg Beta")), na.rm = TRUE),
      min.beta = min(dplyr::c_across(dplyr::contains("Avg Beta")), na.rm = TRUE),
      max.beta = max(dplyr::c_across(dplyr::contains("Avg Beta")), na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      avg.mip = mean(dplyr::c_across(dplyr::contains("MIP")), na.rm = TRUE),
      min.mip = min(dplyr::c_across(dplyr::contains("MIP")), na.rm = TRUE),
      max.mip = max(dplyr::c_across(dplyr::contains("MIP")), na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      avg.nonzero = mean(dplyr::c_across(dplyr::contains("Avg Nonzero Beta")), na.rm = TRUE),
      min.nonzero = min(dplyr::c_across(dplyr::contains("Avg Nonzero Beta")), na.rm = TRUE),
      max.nonzero = max(dplyr::c_across(dplyr::contains("Avg Nonzero Beta")), na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(Variables, avg.beta, min.beta, max.beta,
                  avg.mip, min.mip, max.mip,
                  avg.nonzero, min.nonzero, max.nonzero)
  colnames(data) = c("Variable", "Avg Beta", "Min Beta", "Max Beta",
                           "Avg MIP", "Min MIP", "Max MIP",
                           "Avg Nonzero Beta", "Min Nonzero Beta", "Max Nonzero Beta")

  class(data) <- c("ssvs_summary", class(data))
  data
}







