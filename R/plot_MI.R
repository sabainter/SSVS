#' Plot SSVS-MI Estimates and Marginal Inclusion Probabilities (MIP)
#'
#' This function creates a plot of SSVS-MI estimates with minimum and maximum and a plot for marginal
#' inclusion probabilities (MIP) optional thresholds for highlighting significant predictors..
#'
#' @param x An ssvs result object obtained from [`ssvs_mi()`]
#' @param type Defaults to "both", can change to "estimate" or "MIP".
#' @param est_title A character string specifying the plot title. Defaults to `"SSVS-MI estimates"`.
#' @param threshold A numeric value (between 0 and 1) specifying the MIP threshold to highlight significant predictors.
#'   Defaults to 0.5.
#' @param legend Logical indicating whether to include a legend for the threshold. Defaults to `TRUE`.
#' @param mip_title A character string specifying the plot title. Defaults to `"Multiple Inclusion Probability for SSVS-MI"`.
#' @param color Logical indicating whether to use color to highlight thresholds. Defaults to `TRUE`.
#' @param ... Ignored
#' @return Two `ggplot2` objects representing the plot of SSVS estimates and the plot of MIP with thresholds.
#' @examples
#' \donttest{
#' data(imputed_mtcars)
#' outcome <- 'qsec'
#' predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt', 'vs', 'am', 'gear', 'carb','mpg')
#' imputation <- '.imp'
#' results <- ssvs_mi(data = imputed_mtcars, y = outcome, x = predictors, imp = imputation)
#' plot(results)
#' }
#' @export
plot.ssvs_mi <- function(x, type = "both", threshold = 0.5, legend = TRUE,
                         est_title = NULL, mip_title = NULL, color = TRUE, ...) {
  assert_ssvs_mi(x)
  checkmate::assert_number(threshold, lower = 0, upper = 1, null.ok = TRUE)
  checkmate::assert_logical(legend, len = 1, any.missing = FALSE)
  checkmate::assert_string(est_title, null.ok = TRUE)
  checkmate::assert_string(mip_title, null.ok = TRUE)

  vars = c("Avg Beta", "MIP")
  vars_out = c("Variables", "avg.beta", "min.beta", "max.beta",
               "avg.mip", "min.mip", "max.mip")
  vars_names = c("Variables", "Avg Beta", "Min Beta", "Max Beta",
                 "Avg MIP", "Min MIP", "Max MIP")
  temp <- x %>%
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
    dplyr::ungroup() %>%
    dplyr::select(vars_out[1], vars_out[2], vars_out[3], vars_out[4],
                  vars_out[5], vars_out[6], vars_out[7])

  data <- temp
  colnames(data) <- c("Variables", "Avg Beta", "Min Beta", "Max Beta",
                      "Avg MIP", "Min MIP", "Max MIP")


  if (is.null(est_title)) {
    est_title <- "SSVS-MI estimates"
  }

  p1 <- ggplot2::ggplot(data=data, ggplot2::aes(x = .data[["Variables"]],
                                            y = .data[["Avg Beta"]])) +
      ggplot2::geom_errorbar(
        ggplot2::aes(ymin = .data[["Min Beta"]], ymax = .data[["Max Beta"]]),
        position = "dodge", width = 0.2
      ) +
      ggplot2::geom_point() +
      ggplot2::labs(
        title = est_title,
        x = "Variables",
        y = "Mean Coefficients"
      ) +
      ggplot2::theme_classic()

  plotDF <- temp
  plotDF <- plotDF[order(-plotDF$avg.mip),]

  if (is.null(threshold)) {
    plotDF$threshold <- as.factor(0)
  } else {
    plotDF$threshold <- ifelse(plotDF$avg.mip > threshold, 1, 0)
    plotDF$threshold <- factor(plotDF$threshold, levels = c(0, 1))
    levels(plotDF$threshold) <- c(paste0('< ', threshold), paste0('> ', threshold))
  }

  if (is.null(mip_title)) {
    mip_title <- "Marginal Inclusion Probability for SSVS-MI"
  }

  if (color) {
    cols <- c("#FF4D1C", "#225C3E")
  } else {
    cols <- c("black", "black")
  }

  p2 <- ggplot2::ggplot(data = plotDF) +
    ggplot2::geom_point(ggplot2::aes(x = stats::reorder(.data[["Variables"]], -.data[["avg.mip"]]),
                                     y = .data[["avg.mip"]],
                                     shape = .data[["threshold"]],
                                     color = .data[["threshold"]]),
                        linewidth = 2) +
    ggplot2::geom_errorbar(ggplot2::aes(x = .data[["Variables"]],
                                        y = .data[["avg.mip"]],
                                        ymin = .data[["min.mip"]],
                                        ymax = .data[["max.mip"]]),
                           width = .10,
                           position = "dodge") +
    ggplot2::labs(y = "Marginal Inclusion Probability",
                  x = "Predictor variables",
                  title = mip_title) +
    ggplot2::scale_y_continuous(limits = c(0,1.1), breaks = c(0, .25, .5, .75, 1)) +
    ggplot2::scale_color_manual(values = cols) +
    ggplot2::theme_classic() +
    ggplot2::geom_vline(xintercept = nrow(plotDF)+.5, linetype = 1, linewidth = .5, alpha = .2) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1),
                   panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(),
                   strip.placement = "outside")

  if (!is.null(threshold)) {
    p2 <- p2 +
      ggplot2::labs(shape = "MIP threshold", color = "MIP threshold") +
      ggplot2::geom_hline(yintercept = threshold, linetype = 2)
    if (legend) {
      p2 <- p2 + ggplot2::guides(shape = "legend", color = "legend")
    } else {
      p2 <- p2 + ggplot2::guides(shape = "none", color = "none")  # Correctly disable the legends using "none"
    }
  }

  if (type=="both") {
    gridExtra::grid.arrange(p1,p2)
  } else if (type=="estimate") {
    p1
  } else if (type=="MIP") {
    p2
  }


}






