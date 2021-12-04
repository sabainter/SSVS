
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SSVSforPsych

<!-- badges: start -->

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
| :------- | :----: | :----------: | :---------------: | :----------------: | :------------------: |
| wt       | 0.8545 |    1.0403    |      0.0000       |       1.9470       |        1.2174        |
| vs       | 0.7536 |    0.6498    |      0.0000       |       1.2108       |        0.8623        |
| hp       | 0.5553 |   \-0.5175   |     \-1.3325      |       0.0000       |       \-0.9319       |
| cyl      | 0.4550 |   \-0.5101   |     \-1.7656      |       0.0000       |       \-1.1209       |
| am       | 0.4210 |   \-0.3012   |     \-1.0250      |       0.0000       |       \-0.7154       |
| disp     | 0.3892 |   \-0.4235   |     \-1.8198      |       0.0000       |       \-1.0880       |
| carb     | 0.3874 |   \-0.2761   |     \-1.0035      |       0.0000       |       \-0.7127       |
| gear     | 0.2067 |   \-0.0929   |     \-0.5410      |       0.0000       |       \-0.4493       |
| mpg      | 0.1789 |    0.0701    |     \-0.0019      |       0.5251       |        0.3921        |
| drat     | 0.0981 |   \-0.0176   |      0.0000       |       0.0000       |       \-0.1794       |

The MIPs for each predictor can then be visualized using the
plot\_SSVS() function.

``` r
plot_SSVS('qsec', results)
```

<img src="man/figures/README-plot-1.png" width="100%" />
