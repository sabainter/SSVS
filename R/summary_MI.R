#' Calculate Summary Statistics for SSVS-MI Results
#'
#' Computes summary statistics (average, minimum, and maximum) for beta coefficients and MIP
#' from an SSVS result object.
#'
#' @param x An SSVS result object or a compatible data frame containing model estimates.
#' @return A data frame with variables, average, minimum, and maximum for beta coefficients and MIP
#' @examples
#' \donttest{
#' data(imputed_mtcars)
#' outcome <- 'qsec'
#' predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt', 'vs', 'am', 'gear', 'carb','mpg')
#' imputation <- '.imp'
#' results <- ssvs_mi(data = imputed_mtcars, y = outcome, x = predictors, imp = imputation)
#' summary_est <- summary.est(results)
#' print(summary_est)
#' summary_mip <- summary.mip(results)
#' print(summary_mip)
#' }
#' @export
summary.est <- function(data) {
  assert_ssvs(data)

  data <- data %>%
    as.data.frame() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      avg.beta = mean(dplyr::c_across(dplyr::contains("Avg Beta")), na.rm = TRUE),
      min = min(dplyr::c_across(dplyr::contains("Avg Beta")), na.rm = TRUE),
      max = max(dplyr::c_across(dplyr::contains("Avg Beta")), na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(Variables, avg.beta, min, max)

  class(data) <- c("ssvs_summary", class(data))
  data
}


summary.mip <- function(data) {
  assert_ssvs(data)

  data <- data %>%
    as.data.frame() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      avg.mip = mean(dplyr::c_across(dplyr::contains("MIP")), na.rm = TRUE),
      min = min(dplyr::c_across(dplyr::contains("MIP")), na.rm = TRUE),
      max = max(dplyr::c_across(dplyr::contains("MIP")), na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(Variables, avg.mip, min, max)

  class(data) <- c("ssvs_summary", class(data))
  data
}







