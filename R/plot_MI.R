#' Plot SSVS-MI Estimates with Confidence Intervals
#'
#' This function creates a plot of SSVS-MI estimates with confidence intervals for multiple conditions.
#'
#' @param data A data frame containing the summary statistics for SSVS results. Must include columns
#'   `Variables`, `avg.beta`, `min`, and `max` with option `Condition`.
#' @param ty A character vector specifying the order of conditions in the plot.
#' @param pal A character vector of colors corresponding to the conditions.
#' @return A `ggplot2` object representing the SSVS estimates plot.
#' @examples
#' \donttest{
#' data(example_data)
#' outcome <- "yMCAR40"
#' predictors <- c("xMCAR40_1", "xMCAR40_2", "xMCAR40_3", "xMCAR40_4", "xMCAR40_5")
#' results <- SSVS_MI(data = example_data, y = outcome, x = predictors, imputations = 3, replications = 3)
#' summary_stats <- summary_MI(results)
#' plot_ssvs_est(summary_stats, cond=FALSE)
#' }
#' @export
plot_ssvs_est <- function(data, ty=NA, pal=NA, Condition=NA, cond=TRUE, title=NULL) {
  checkmate::assert_data_frame(data, min.cols = 5)
  checkmate::assert_character(ty, min.len = 1)
  checkmate::assert_character(pal, len = length(ty))

  if (is.null(title)) {
    title <- "SSVS-MI estimates"
  }

  if (cond) {
    if (sum(is.na(ty))>0) {
      stop("please input `ty`")
    }
    if (sum(is.na(pal))>0) {
      stop("please input `pal`")
    }
    if (sum(is.na(Condition))>0) {
      stop("please input `Condition`")
    }
  }

  if (cond) {

  data$Condition = Condition
  data$Condition = factor(data$Condition, levels=ty)

  plt <- ggplot2::ggplot(data, ggplot2::aes(x = forcats::fct_inorder(Variables), y = avg.beta)) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = min, ymax = max, colour = Condition),
      position = "dodge"
    ) +
    ggplot2::scale_color_manual("Condition", values = setNames(pal, ty)) +
    ggplot2::geom_point(
      ggplot2::aes(fill = Condition, shape = Condition, colour = Condition),
      position = ggplot2::position_dodge(0.9)
    ) +
    ggplot2::scale_fill_manual("Condition", values = setNames(pal, ty)) +
    ggplot2::ggtitle(title) +
    ggplot2::xlab("Variables") +
    ggplot2::ylab("Mean Coefficients") +
    ggplot2::theme_bw() +
    ggplot2::theme_classic()

  } else {

  plt <- ggplot2::ggplot(data, ggplot2::aes(x = forcats::fct_inorder(Variables), y = avg.beta)) +
      ggplot2::geom_errorbar(
        ggplot2::aes(ymin = min, ymax = max),
        position = "dodge", width = 0.2
      ) +
      ggplot2::geom_point() +
      ggplot2::labs(
        title = title,
        x = "Variables",
        y = "Mean Coefficients"
      ) +
      ggplot2::theme_classic()
  }

  plt
}
