test_that("is_ssvs", {
  expect_error(is_ssvs())
  expect_false(is_ssvs(NULL))
  expect_false(is_ssvs("string"))
  expect_true(is_ssvs(ssvs(mtcars, x = c("mpg", "cyl", "disp"), y = "qsec", progress = FALSE)))
})


test_that("assert_ssvs", {
  expect_error(assert_ssvs())
  expect_error(assert_ssvs(NULL))
  expect_error(assert_ssvs("string"))
  expect_true(assert_ssvs(ssvs(mtcars, x = c("mpg", "cyl", "disp"), y = "qsec", progress = FALSE)))
})
