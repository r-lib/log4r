#' Write logs at a given level
#'
#' @param logger An object of class `"logger"`.
#' @param level The desired severity, one of `"DEBUG"`, `"INFO"`, `"WARN"`,
#'   `"ERROR"`, or `"FATAL"`. Messages with a lower severity than the logger
#'   threshold will be discarded.
#' @param ... One or more items to log.
#' @return `invisible(NULL)`, called for the side effect of writing to the
#'   logger's appenders.
#' @examples
#' logger <- logger()
#'
#' log_at(logger, "WARN", "First warning from our code")
#' log_debug(logger, "Debugging our code")
#' log_info(logger, "Information about our code")
#' log_warn(logger, "Another warning from our code")
#' log_error(logger, "An error from our code")
#' log_fatal(logger, "I'm outta here")
#' @export
log_at <- function(logger, level, ...) {
  level <- as_level(level)
  if (logger$threshold > level) {
    return(invisible(NULL))
  }
  for (appender in logger$appenders) {
    appender(LEVEL_NAMES[level], ...)
  }
}

#' @rdname log_at
#' @export
log_debug <- function(logger, ...) {
  if (logger$threshold > DEBUG) {
    return(invisible(NULL))
  }
  for (appender in logger$appenders) {
    appender("DEBUG", ...)
  }
}

#' @rdname log_at
#' @export
log_info <- function(logger, ...) {
  if (logger$threshold > INFO) {
    return(invisible(NULL))
  }
  for (appender in logger$appenders) {
    appender("INFO", ...)
  }
}

#' @rdname log_at
#' @export
log_warn <- function(logger, ...) {
  if (logger$threshold > WARN) {
    return(invisible(NULL))
  }
  for (appender in logger$appenders) {
    appender("WARN", ...)
  }
}

#' @rdname log_at
#' @export
log_error <- function(logger, ...) {
  if (logger$threshold > ERROR) {
    return(invisible(NULL))
  }
  for (appender in logger$appenders) {
    appender("ERROR", ...)
  }
}

#' @rdname log_at
#' @export
log_fatal <- function(logger, ...) {
  # NOTE: It should not be possible to have a higher threshold, so don't check.
  for (appender in logger$appenders) {
    appender("FATAL", ...)
  }
}
