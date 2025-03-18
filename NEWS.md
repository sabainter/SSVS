# SSVS 2.1.0 (2025-03-18)

- Added functions for SSVS with multiply imputed data
- Added an example demonstrating SSVS for multiply imputed data

# SSVS 2.0.0 (2022-05-27)

- BREAKING CHANGE: Swapped `x` and `y` parameters of `ssvs()`
- BREAKING CHANGE: Changed default `interval` parameter of `summary()`
- BREAKING CHANGE: Changed the order of columns in the result of `summary()`
- Added a `launch()` function that launches a shiny app for SSVS
- Add a boolean `color` parameter to `plot()`
- Don't automatically print the result of `summary()` to the console since it doesn't allow you to properly save the result to a variable
- Added reference to package DESCRIPTION
- Clarified documentation about scaling in `summary()`

# SSVS 1.0.0 (2022-03-08)

Initial CRAN version
