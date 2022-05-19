expect_summary_eq <- function(x, y) {
  class(x) <- setdiff(class(x), "ssvs_summary")
  class(y) <- setdiff(class(y), "ssvs_summary")
  expect_equal(x, y)
}

test_that("summary works", {
  predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
  outcome <- "qsec"

  set.seed(1000)
  results_simple <- ssvs(data = mtcars, x = predictors, y = outcome, progress = FALSE)
  summary_simple <- read.csv(system.file("testdata/summary_simple.csv", package = "SSVS"), check.names = FALSE)
  expect_s3_class(summary(results_simple), "ssvs_summary")
  expect_summary_eq(summary_simple, summary(results_simple, interval = 0.95))
  summary_ordered <- summary_simple[order(summary_simple$MIP, decreasing = TRUE), ]
  expect_summary_eq(summary_ordered, summary(results_simple, interval = 0.95, ordered = TRUE))
  expect_equal(nrow(summary(results_simple, interval = 0.95, threshold = 0.5)), 3)
})
