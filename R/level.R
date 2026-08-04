#' Set the logging threshold level for a logger dynamically
#'
#' It can sometimes be useful to change the logging threshold level at runtime.
#' The [`level()`] accessor allows doing so.
#'
#' @param x An object of class `"logger"`.
#' @param value One of `"DEBUG"`, `"INFO"`, `"WARN"`, `"ERROR"`, or `"FATAL"`.
#'
#' @return `level()` returns the logger's threshold and `level<-()` returns the
#'   modified logger. `available.loglevels()` returns a named list of all
#'   thresholds.
#'
#' @examples
#' lgr <- logger()
#' level(lgr) # Prints "INFO".
#' info(lgr, "This message is shown.")
#' level(lgr) <- "FATAL"
#' info(lgr, "This message is now suppressed.")
#' @export
level <- function(x) {
  UseMethod("level", x)
}

#' @rdname level
#' @export
`level<-` <- function(x, value) {
  UseMethod("level<-", x)
}

#' @rdname level
#' @export
level.logger <- function(x) x$threshold

#' @rdname level
#' @export
`level<-.logger` <- function(x, value) {
  x$threshold <- as_level(value)
  x
}

# Converts strings like "INFO" or "ERROR" to the internal level representation.
# For historical reasons we also accept integers.
as_level <- function(i) {
  if (inherits(i, "loglevel")) {
    return(i)
  }

  idx <- NULL
  if (length(i) == 1 && is.numeric(i)) {
    idx <- max(min(i, length(LEVELS)), 1)
  } else if (length(i) == 1 && is.character(i)) {
    idx <- which(i == levels(LEVELS))
  }

  if (length(idx) == 0) {
    arg <- rlang::caller_arg(i)
    levels <- cli::cli_vec(LEVEL_NAMES, style = list("vec-last" = ", or "))
    cli::cli_abort(
      "{.arg {arg}} must be one of {.str {levels}}.",
      call = rlang::caller_env()
    )
  }

  structure(LEVELS[idx], class = "loglevel")
}

# Internal constants.
LEVEL_NAMES <- c("DEBUG", "INFO", "WARN", "ERROR", "FATAL")
LEVELS <- factor(LEVEL_NAMES, levels = LEVEL_NAMES, ordered = TRUE)
DEBUG <- as_level("DEBUG")
INFO <- as_level("INFO")
WARN <- as_level("WARN")
ERROR <- as_level("ERROR")
FATAL <- as_level("FATAL")

#' @rdname level
#' @export
available.loglevels <- function() {
  lapply(stats::setNames(nm = LEVEL_NAMES), as_level)
}
