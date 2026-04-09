## R CMD check results

0 errors | 0 warnings | 1 note

* The note is related to future file timestamps and is not a functional issue.
* All examples are wrapped in \donttest{} to avoid long runtime and randomness during CRAN checks.
* The package has been tested locally on macOS and via GitHub Actions on macOS, Windows, and Ubuntu.

## Changes in this version

* This is an update to the package.
* Added new arguments `prior.probs` and `force.in` to `ssvs()`.
* Deprecated the `inprob` argument (still supported with a warning).
* Updated documentation and examples to reflect the new interface.
* Improved test coverage and reproducibility.
