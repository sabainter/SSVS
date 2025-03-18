#' Calculate Summary Statistics for SSVS-MI Results
#'
#' Computes summary statistics (average, minimum, and maximum) for beta coefficients, MIP and
#' average nonzero beta coefficients from an SSVS result object.
#'
#' @param object An ssvs_mi result object obtained from [`ssvs_mi()`]
#' @param ... Ignored
#' @examples
#' \donttest{
#' data(imputed_mtcars)
#' outcome <- 'qsec'
#' predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt', 'vs', 'am', 'gear', 'carb','mpg')
#' imputation <- '.imp'
#' results <- ssvs_mi(data = imputed_mtcars, y = outcome, x = predictors, imp = imputation)
#' summary_MI<-summary(results)
#' print(summary_MI)
#' }
#' @return A data frame with results
#' @export
summary.ssvs_mi <- function(object, ...) {
  assert_ssvs_mi(object)

  vars = c("Avg Beta", "MIP", "Avg Nonzero Beta")
  vars_out = c("Variables", "avg.beta", "min.beta", "max.beta",
               "avg.mip", "min.mip", "max.mip",
               "avg.nonzero", "min.nonzero", "max.nonzero")
  res <- object %>%
    as.data.frame() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      avg.beta = mean(dplyr::c_across(dplyr::contains(vars[1])), na.rm = TRUE),
      min.beta = min(dplyr::c_across(dplyr::contains(vars[1])), na.rm = TRUE),
      max.beta = max(dplyr::c_across(dplyr::contains(vars[1])), na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      avg.mip = mean(dplyr::c_across(dplyr::contains(vars[2])), na.rm = TRUE),
      min.mip = min(dplyr::c_across(dplyr::contains(vars[2])), na.rm = TRUE),
      max.mip = max(dplyr::c_across(dplyr::contains(vars[2])), na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      avg.nonzero = mean(dplyr::c_across(dplyr::contains(vars[3])), na.rm = TRUE),
      min.nonzero = min(dplyr::c_across(dplyr::contains(vars[3])), na.rm = TRUE),
      max.nonzero = max(dplyr::c_across(dplyr::contains(vars[3])), na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(vars_out[1], vars_out[2], vars_out[3], vars_out[4],
                  vars_out[5], vars_out[6], vars_out[7],
                  vars_out[8], vars_out[9], vars_out[10])

  colnames(res) <- c("Variable", "Avg Beta", "Min Beta", "Max Beta",
                     "Avg MIP", "Min MIP", "Max MIP",
                     "Avg Nonzero Beta", "Min Nonzero Beta", "Max Nonzero Beta")

  class(res) <- c("ssvs_mi_summary", class(res))
  res
}


#' Print the summary of ssvs_mi
#' @export
#' @keywords internal
print.ssvs_mi_summary <- function(x, ...) {
  print.data.frame(x, right = FALSE, row.names = FALSE)
}



