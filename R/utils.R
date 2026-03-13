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

compute_inclusion_probs <- function(x,
                                    prior.probs = NULL,
                                    force.in = NULL,
                                    expected.model.size = NULL) {

  n_vars <- length(x)

  ## Step 1: Create base prior probabilities
  if (!is.null(prior.probs)) {
    # User provided explicit probabilities
    probs <- prior.probs

    # Validation
    if (length(probs) == 1) {
      # Scalar - replicate for all variables
      probs <- rep(probs, n_vars)
    } else if (length(probs) != n_vars) {
      stop("prior.probs must have length 1 or length(x) = ",
           n_vars)
    }

    if (any(probs < 0) || any(probs > 1)) {
      stop("All prior.probs must be between 0 and 1")
    }

  } else {
    # Default: Use expected model size
    if (is.null(expected.model.size)) {
      expected.model.size <- 1
    }

    # Account for forced variables
    n_forced <- if (!is.null(force.in)) length(force.in) else 0
    n_selectable <- n_vars - n_forced

    if (expected.model.size >= n_vars) {
      # Include everything
      probs <- rep(1.0, n_vars)
    } else {
      expected_selected <- max(0, expected.model.size - n_forced)
      prob_selectable <- expected_selected / n_selectable
      probs <- rep(prob_selectable, n_vars)
    }
  }

  ## Step 2: Override probabilities for forced variables
  if (!is.null(force.in)) {
    force_idx <- validate_force_in(force.in, x)
    probs[force_idx] <- 1.0

    # Warn if user also specified probs for forced vars
    if (!is.null(prior.probs) &&
        any(prior.probs[force_idx] < 1.0)) {
      warning("Overriding prior.probs for forced variables to 1.0")
    }
  }

  return(probs)
}

validate_force_in <- function(force.in, x) {
  if (is.null(force.in)) return(NULL)

  if (is.character(force.in)) {
    force_idx <- match(force.in, x)
    if (any(is.na(force_idx))) {
      missing <- force.in[is.na(match(force.in, x))]
      stop("Variables not found: ", paste(missing, collapse = ", "))
    }
  }
  } else {
    stop("force.in variables not found in x)
  }

  return(force_idx)
}
