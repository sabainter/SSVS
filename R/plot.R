#' Plot results of an SSVS model
#'
#' @param x An SSVS result object obtained from [`ssvs()`]
#' @param y The name of the dependent variable
#' @param threshold An MIP threshold to show on the plot, must be between 0-1.
#' If `NULL`, no threshold is used.
#' @param legend If `TRUE`, show a legend for the shapes based on the threshold.
#' Ignored if `threshold = NULL`.
#' @param title The title of the plot
#' @param ... Ignored
#' @examples
#' outcome <- "qsec"
#' predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
#' results <- ssvs(x = predictors, y = outcome, data = mtcars, plot = FALSE)
#' plot(results, outcome)
#' @return Creates a plot of the inclusion probabilities by variable
#' @export
#' @importFrom rlang .data
plot.ssvs <- function(x, y, threshold = 0.5, legend = TRUE,
                      title = paste("Inclusion Probability for", y),
                      ...) {
  assert_ssvs(x)
  checkmate::assert_string(y)
  checkmate::assert_number(threshold, lower = 0, upper = 1)
  checkmate::assert_logical(legend, len = 1, any.missing = FALSE)
  checkmate::assert_string(title)

  #Recreate a dataframe of the results
  plotDF <- as.data.frame(apply(x$beta!=0,2,mean))
  plotDF$var <- rownames(plotDF)
  plotDF$DV <- as.character(y)
  names(plotDF) <- c("Inclusion_probability","Variable_name","Dependent_variable")
  plotDF <- plotDF[order(-plotDF$Inclusion_probability),]

  if (is.null(threshold)) {
    plotDF$threshold <- as.factor(0)
  } else {
    plotDF$threshold <- ifelse(plotDF$Inclusion_probability > threshold, 1, 0)
    plotDF$threshold <- as.factor(plotDF$threshold)
    levels(plotDF$threshold) <- c(paste0('< ', threshold), paste0('> ', threshold))
  }

  plt <- ggplot2::ggplot(data = plotDF) +
    ggplot2::geom_point(ggplot2::aes(x = stats::reorder(.data[["Variable_name"]], -.data[["Inclusion_probability"]]),
                                     y = .data[["Inclusion_probability"]],
                                     shape = .data[["threshold"]]),
                        size = 2) +
    ggplot2::labs(y = "Inclusion Probability",
                  x = "Predictor variables",
                  title = title) +
    ggplot2::scale_y_continuous(limits = c(0,1.1), breaks = c(0, .25, .5, .75, 1)) +
    ggplot2::theme_classic() +
    ggplot2::geom_vline(xintercept = nrow(plotDF)+.5, linetype = 1, size = .5, alpha = .2) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1),
                   panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(),
                   strip.placement = "outside") +
    ggplot2::guides(shape = FALSE)

  if (!is.null(threshold)) {
    plt <- plt +
      ggplot2::labs(shape = "MIP threshold") +
      ggplot2::geom_hline(yintercept = threshold, linetype = 2)
    if (legend) {
      plt <- plt + ggplot2::guides(shape = ggplot2::guide_legend())
    }
  }

  plt
}

