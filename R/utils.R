is_ssvs <- function(x) {
  inherits(x, "ssvs")
}

assert_ssvs <- function(x) {
  if (!is_ssvs(x)) {
    stop("You must provide an SSVS object", call. = FALSE)
  }
  invisible(TRUE)
}

assert_ssvs_mi <- function(object) {
  if (!inherits(object, "ssvs_mi")) {
    stop("The input must be an object of class 'ssvs_mi'.", call. = FALSE)
  }
}
