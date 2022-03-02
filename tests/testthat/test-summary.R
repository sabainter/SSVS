test_that("summary works", {
  predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
  outcome <- "qsec"

  set.seed(1000)
  results_simple <- ssvs(data = mtcars, x = predictors, y = outcome, progress = FALSE)
  summary_simple <- read.csv(system.file("testdata/summary_simple.csv", package = "SSVS"), check.names = FALSE)
  expect_equal(summary_simple, summary(results_simple))
  summary_ordered <- summary_simple[order(summary1$MIP, decreasing = TRUE), ]
  expect_equal(summary_ordered, summary(results_simple, ordered = TRUE))
  expect_equal(nrow(summary(results_simple, threshold = 0.5)), 3)

  data(Affairs, package = "AER")
  Affairs$hadaffair[Affairs$affairs > 0] <- 1
  Affairs$hadaffair[Affairs$affairs == 0] <- 0
  outcome <- "hadaffair"
  predictors <- c("gender", "age", "yearsmarried", "children", "religiousness",
                  "education", "occupation", "rating")
  set.seed(1000)
  results_binary <- ssvs(Affairs, predictors, outcome, continuous = FALSE, progress = FALSE)
  summary_binary <- read.csv(system.file("testdata/summary_binary.csv", package = "SSVS"), check.names = FALSE)
  expect_equal(summary_binary, summary(results_binary))
})
