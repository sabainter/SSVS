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
#' data(imputed_mtcars)
#' outcome <- 'qsec'
#' predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt', 'vs', 'am', 'gear', 'carb','mpg')
#' imputation <- '.imp'
#' results <- ssvs_mi(data = imputed_mtcars, y = outcome, x = predictors, imp = imputation)
#' summary_est <- summary.est(results)
#' summary_mip <- summary.mip(results)
#' plot.est(summary_est)
#' plot.mip(summary_mip)
#' }
#' @export
plot.est <- function(data, title=NULL) {
  checkmate::assert_data_frame(data, min.cols = 4)
  checkmate::assert_string(title, null.ok = TRUE)

  if (is.null(title)) {
    title <- "SSVS-MI estimates"
  }

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

  plt
}

plot.mip <- function(data, threshold = 0.5, legend = TRUE, title = NULL, color = TRUE) {
  checkmate::assert_data_frame(data, min.cols = 4)
  checkmate::assert_number(threshold, lower = 0, upper = 1, null.ok = TRUE)
  checkmate::assert_logical(legend, len = 1, any.missing = FALSE)
  checkmate::assert_string(title, null.ok = TRUE)

  plotDF <- data[order(-data$avg.mip),]

  if (is.null(threshold)) {
    plotDF$threshold <- as.factor(0)
  } else {
    plotDF$threshold <- ifelse(plotDF$avg.mip > threshold, 1, 0)
    plotDF$threshold <- factor(plotDF$threshold, levels = c(0, 1))
    levels(plotDF$threshold) <- c(paste0('< ', threshold), paste0('> ', threshold))
  }

  if (is.null(title)) {
    title <- "Multiple Inclusion Probability for SSVS-MI"
  }

  if (color) {
    cols <- c("#FF4D1C", "#225C3E")
  } else {
    cols <- c("black", "black")
  }

  plt <- ggplot2::ggplot(data = plotDF) +
    ggplot2::geom_point(ggplot2::aes(x = stats::reorder(.data[["Variables"]], -.data[["avg.mip"]]),
                                     y = .data[["avg.mip"]],
                                     shape = .data[["threshold"]],
                                     color = .data[["threshold"]]),
                        size = 2) +
    ggplot2::geom_errorbar(aes(x = .data[["Variables"]],
                               y = .data[["avg.mip"]],
                               ymin = .data[["min"]],
                               ymax = .data[["max"]]),
                           width = .10,
                           position = "dodge") +
    ggplot2::labs(y = "Multiple Inclusion Probability",
                  x = "Predictor variables",
                  title = title) +
    ggplot2::scale_y_continuous(limits = c(0,1.1), breaks = c(0, .25, .5, .75, 1)) +
    ggplot2::scale_color_manual(values = cols) +
    ggplot2::theme_classic() +
    ggplot2::geom_vline(xintercept = nrow(plotDF)+.5, linetype = 1, size = .5, alpha = .2) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1),
                   panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(),
                   strip.placement = "outside")

  if (!is.null(threshold)) {
    plt <- plt +
      ggplot2::labs(shape = "MIP threshold", color = "MIP threshold") +
      ggplot2::geom_hline(yintercept = threshold, linetype = 2)
    if (legend) {
      plt <- plt + ggplot2::guides(shape = "legend", color = "legend")
    } else {
      plt <- plt + ggplot2::guides(shape = "none", color = "none")  # Correctly disable the legends using "none"
    }
  }

  plt
}







