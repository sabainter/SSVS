
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
# install.packages("remotes")
remotes::install_github("sabainter/SSVSforPsych")
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
 y= outcome, data = mtcars, plot = F)
```

The results can be summarized and printed using the summary\_SSVS()
function. This will display both the MIP for each predictor, as well as
the probable range of values for each coefficient.

``` r
summary_results <- summary_SSVS(results, interval=.9, order="MIP Descending")
```

| Variable |  MIP   | Average Beta | Beta Low CI (90%) | Beta High CI (90%) | Average nonzero Beta |
|:---------|:------:|:------------:|:-----------------:|:------------------:|:--------------------:|
| wt       | 0.8600 |    1.0974    |      0.0000       |       1.9984       |        1.2761        |
| vs       | 0.7818 |    0.6682    |      0.0000       |       1.2019       |        0.8547        |
| hp       | 0.5330 |   -0.4988    |      -1.3380      |       0.0000       |       -0.9357        |
| disp     | 0.4266 |   -0.4968    |      -1.8255      |       0.0012       |       -1.1647        |
| carb     | 0.4236 |   -0.3169    |      -1.0301      |       0.0000       |       -0.7480        |
| cyl      | 0.4002 |   -0.4489    |      -1.7527      |       0.0000       |       -1.1218        |
| am       | 0.3828 |   -0.2761    |      -1.0345      |       0.0000       |       -0.7214        |
| gear     | 0.1905 |   -0.0831    |      -0.4969      |       0.0000       |       -0.4359        |
| mpg      | 0.1859 |    0.0705    |      0.0000       |       0.5258       |        0.3794        |
| drat     | 0.0995 |   -0.0171    |      0.0000       |       0.0000       |       -0.1720        |

The MIPs for each predictor can then be visualized using the
plot\_SSVS() function.

``` r
plot_SSVS('qsec', results)
```

<img src="man/figures/README-plot-1.png" width="100%" />
