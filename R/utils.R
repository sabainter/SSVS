is_ssvs <- function(x) {
  inherits(x, "ssvs")
}

assert_ssvs <- function(x) {
  if (!is_ssvs(x)) {
    stop("You must provide an SSVS object", call. = FALSE)
  }
  invisible(TRUE)
}
