#' SSVS plot function
#'
#' @param y The name of the dependent variable
#' @param ssvs.results The result list from running the SSVS function
#' @return Creates a plot of the inclusion probabilities by variable
#' @export
#'
#' @importFrom ggplot2 ggplot geom_point labs scale_y_continuous theme_classic geom_vline geom_hline theme aes element_text unit element_blank
#'

plot_SSVS <- function(y,ssvs.results){
  #Recreate a dataframe of the results
  plotDF <- as.data.frame(apply(ssvs.results$beta!=0,2,mean))
  plotDF$var <- rownames(plotDF)
  plotDF$DV <- as.character(y)
  names(plotDF) <- c("Inclusion_probability","Variable_name","Dependent_variable")
  plotDF <- plotDF[order(-plotDF$Inclusion_probability),]

  plotDF$threshold <- ifelse(plotDF$Inclusion_probability>.5, 1, 0)
  plotDF$threshold <- as.factor(plotDF$threshold)
  levels(plotDF$threshold) <- c('< .50', '> .50')

  suppressWarnings(ggplot2::ggplot(data=plotDF) +
    ggplot2::geom_point(ggplot2::aes(x = reorder(plotDF$Variable_name,-plotDF$Inclusion_probability),
                   y = plotDF$Inclusion_probability,
                   shape = plotDF$threshold),
               size = 2) +
      ggplot2::labs(y = "Inclusion Probability",
         x = "Predictor variables",
         shape = "MIP threshold",
         title = paste("Inclusion Probability for", y)) +
      ggplot2::scale_y_continuous(limits = c(0,1.1), breaks = c(0, .25, .5, .75, 1)) +
      ggplot2::theme_classic() +
      ggplot2::geom_vline(xintercept = nrow(plotDF)+.5, linetype = 1, size = .5, alpha = .2) +
      ggplot2::geom_hline(yintercept = .5, linetype = 2) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1),
          panel.spacing = ggplot2::unit(0, "lines"),
          strip.background = ggplot2::element_blank(),
          strip.placement = "outside"))

}

