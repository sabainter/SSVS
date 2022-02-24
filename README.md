
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

The results can be summarized and printed using the `summary()`
function. This will display both the MIP for each predictor, as well as
the probable range of values for each coefficient.

``` r
summary_results <- summary(results, interval=.9, order="MIP Descending")
```

| Variable |  MIP   | Average Beta | Beta Low CI (90%) | Beta High CI (90%) | Average nonzero Beta |
|:---------|:------:|:------------:|:-----------------:|:------------------:|:--------------------:|
| wt       | 0.8433 |    1.0433    |      0.0000       |       1.9513       |        1.2372        |
| vs       | 0.7512 |    0.6399    |      0.0000       |       1.1982       |        0.8519        |
| hp       | 0.5413 |   -0.4995    |      -1.3349      |       0.0000       |       -0.9228        |
| cyl      | 0.4551 |   -0.5173    |      -1.7670      |       0.0005       |       -1.1367        |
| am       | 0.4240 |   -0.3107    |      -1.0805      |       0.0000       |       -0.7328        |
| disp     | 0.4130 |   -0.4553    |      -1.8170      |       0.0012       |       -1.1023        |
| carb     | 0.3938 |   -0.2890    |      -1.0068      |       0.0000       |       -0.7338        |
| gear     | 0.2013 |   -0.0918    |      -0.5464      |       0.0002       |       -0.4560        |
| mpg      | 0.1584 |    0.0563    |      -0.0001      |       0.4160       |        0.3557        |
| drat     | 0.1003 |   -0.0180    |      -0.0008      |       0.0000       |       -0.1794        |

The MIPs for each predictor can then be visualized using the `plot()`
function.

``` r
plot(results, 'qsec')
```

<img src="man/figures/README-plot-1.png" width="100%" />
