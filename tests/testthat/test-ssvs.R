test_that("ssvs argument error checking works", {
  predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
  outcome <- "qsec"

  expect_error(ssvs())
  expect_error(ssvs("nodata", x = predictors, y = outcome))
  expect_error(ssvs(mtcars, x = "novar", y = outcome))
  expect_error(ssvs(mtcars, x = predictors, y = "novar"))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, inprob = 2))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, burn = 0))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, burn = 1000, runs = 1000))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, burn = 0))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, burn = 1.5))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, runs = 0))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, a1 = 0))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, b1 = 0))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, prec.beta = 0))
  expect_error(ssvs(mtcars, x = predictors, y = outcome, progress = "nobool"))
})

test_that("ssvs works", {
  predictors <- c("cyl", "disp", "hp", "drat", "wt", "vs", "am", "gear", "carb", "mpg")
  outcome <- "qsec"

  set.seed(1000)
  results_simple <- ssvs(data = mtcars, y = outcome, x = predictors, progress = FALSE)

  # Check structure
  expect_s3_class(results_simple, "ssvs")
  expect_equal(dim(results_simple$beta), c(15001, 10))
  expect_equal(dim(results_simple$pred), c(15001, 25))
  expect_length(results_simple$int, 15001)
  expect_length(results_simple$taue, 15001)
  expect_equal(colnames(results_simple$beta), predictors)

  # Check posterior means are in a reasonable range
  beta_means <- colMeans(results_simple$beta)
  expect_true(all(beta_means > -5 & beta_means < 5))

  # Check precision is positive
  expect_true(all(results_simple$taue > 0))
})
