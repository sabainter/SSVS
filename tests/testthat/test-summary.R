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

  s <- summary(results_simple, interval = 0.95)

  # Check class
  expect_s3_class(s, "ssvs_summary")

  # Check structure
  expect_equal(nrow(s), length(predictors))
  expect_true(all(s$MIP >= 0 & s$MIP <= 1))
  expect_true(all(s$`Lower CI (95%)` <= s$`Upper CI (95%)`))

  # Check known high/low inclusion predictors
  expect_true(s$MIP[s$Variable == "wt"] > 0.5)
  expect_true(s$MIP[s$Variable == "drat"] < 0.2)

  # Check ordering
  s_ordered <- summary(results_simple, interval = 0.95, ordered = TRUE)
  expect_equal(s_ordered$MIP, sort(s$MIP, decreasing = TRUE))

  # Check threshold
  expect_equal(nrow(summary(results_simple, interval = 0.95, threshold = 0.5)), 3)
})
