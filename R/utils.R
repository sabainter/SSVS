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
                                    prior.probs = .5,
                                    force.in = NULL) {

  n_vars <- length(x)

  ## Step 1: Create base prior probabilities
  if (!is.null(prior.probs)) {
    # User provided explicit probabilities
     prior.probs <-.5
  }

    # Validation
    if (length(prior.probs) == 1) {
      # Scalar - replicate for all variables
      probs <- rep(prior.probs, n_vars)
    } else if (length(prior.probs) == n_vars) {
      # Vector - use as provided
      probs <- prior.probs
    } else {
      stop("prior.probs must have length 1 or length(x) = ", n_vars,
      "\nYou provided length ", length(prior.probs),
      call. = FALSE
      )
    }

    if (any(probs < 0) || any(probs > 1)) {
      invalid_idx <- which(probs < 0 | probs > 1)
      stop(
        "All 'prior.probs' values must be between 0 and 1.\n",
        "Invalid values at positions: ", paste(invalid_idx, collapse = ", "),
        call. = FALSE
       )
      }


  ## Step 2: Override probabilities for forced variables
  if (!is.null(force.in)) {
    force_idx <- match(force.in, x)
    if (any(is.na(force_idx))) {
      missing <- force.in[is.na(match(force.in, x))]
      stop(
        "Variables specified in 'force.in' not found in 'x': ",
        paste(missing, collapse = ", "),
        call. = FALSE
      )
    }
    # Warn if overriding user-specified probabilities
    if (length(prior.probs) > 1 && any(prior.probs[force_idx] < 1.0)) {
      warning(
        "Overriding user-specified 'prior.probs' for forced variables to 1.0.\n",
        "Forced variables: ", paste(x[force_idx], collapse = ", "),
        call. = FALSE
      )
    }
    # Set forced variables to probability 1.0
    probs[force_idx] <- 1.0
    }

    #Name and return
    names(probs) <- x
    return(probs)
    }
