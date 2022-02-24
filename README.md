
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SSVSforPsych <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/sabainter/SSVSforPsych/workflows/R-CMD-check/badge.svg)](https://github.com/sabainter/SSVSforPsych/actions)
<!-- badges: end -->

The goal of SSVSforPsych is to provide functions for performing
stochastic search variable selection (SSVS) for binary and continuous
outcomes and visualizing the results. SSVS is a Bayesian variable
selection method used to estimate the probability that individual
predictors should be included in a regression model. Using MCMC
estimation, the method samples thousands of regression models in order
to characterize the model uncertainty regarding both the predictor set
and the regression parameters.

## Installation

You can install the development version of SSVSforPsych from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mahmoud-mfahmy/SSVSforPsych")
```

## Example

Consider a simple example using SSVS on the mtcars dataset to predict
quarter mile times. We first specify our response variable (qsec), then
choose our predictors and run the SSVS function.

``` r
library(SSVSforPsych)
outcome <- 'qsec'
predictors <- c('cyl', 'disp', 'hp', 'drat', 'wt',
 'vs', 'am', 'gear', 'carb','mpg')

results <- SSVS(x = predictors,
 y = outcome, data = mtcars, plot=F)
```

The results can be summarized and printed using the summary\_SSVS()
function. This will display both the MIP for each predictor, as well as
the probable range of values for each coefficient.

``` r
summary_results <- summary_SSVS(results, interval=.9, order="MIP Descending")
```

| Variable |  MIP   | Average Beta | Beta Low CI (90%) | Beta High CI (90%) | Average nonzero Beta |
|:---------|:------:|:------------:|:-----------------:|:------------------:|:--------------------:|
| wt       | 0.8437 |    1.0538    |      0.0000       |       1.9731       |        1.2491        |
| vs       | 0.7771 |    0.6684    |      0.0000       |       1.2072       |        0.8601        |
| hp       | 0.5542 |   -0.5222    |      -1.3410      |       0.0000       |       -0.9424        |
| cyl      | 0.4143 |   -0.4580    |      -1.7547      |       0.0000       |       -1.1056        |
| carb     | 0.4049 |   -0.3005    |      -1.0313      |       0.0000       |       -0.7421        |
| am       | 0.4022 |   -0.2830    |      -1.0249      |       0.0000       |       -0.7038        |
| disp     | 0.4003 |   -0.4547    |      -1.8406      |       0.0000       |       -1.1360        |
| gear     | 0.1970 |   -0.0853    |      -0.5315      |       0.0009       |       -0.4328        |
| mpg      | 0.1595 |    0.0545    |      -0.0036      |       0.4412       |        0.3417        |
| drat     | 0.0889 |   -0.0146    |      0.0000       |       0.0000       |       -0.1642        |

The MIPs for each predictor can then be visualized using the
plot\_SSVS() function.

``` r
plot_SSVS('qsec', results)
```

<img src="man/figures/README-plot-1.png" width="100%" />
