
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SSVSforPsych <img src="man/figures/logo.png" align="right" width="120" />

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
| wt       | 0.8434 |    1.0483    |      0.0000       |       1.9753       |        1.2429        |
| vs       | 0.7615 |    0.6508    |      0.0000       |       1.1965       |        0.8546        |
| hp       | 0.5329 |   \-0.4930   |     \-1.3251      |       0.0000       |       \-0.9251       |
| cyl      | 0.4404 |   \-0.4991   |     \-1.7675      |       0.0000       |       \-1.1332       |
| disp     | 0.4076 |   \-0.4559   |     \-1.8517      |       0.0000       |       \-1.1184       |
| carb     | 0.4068 |   \-0.3010   |     \-1.0200      |       0.0000       |       \-0.7398       |
| am       | 0.3977 |   \-0.2862   |     \-1.0429      |       0.0000       |       \-0.7196       |
| gear     | 0.2063 |   \-0.0987   |     \-0.5967      |       0.0007       |       \-0.4786       |
| mpg      | 0.1533 |    0.0559    |      0.0000       |       0.4193       |        0.3645        |
| drat     | 0.1035 |   \-0.0168   |     \-0.0265      |       0.0000       |       \-0.1621       |

The MIPs for each predictor can then be visualized using the
plot\_SSVS() function.

``` r
plot_SSVS('qsec', results)
```

<img src="man/figures/README-plot-1.png" width="100%" />
