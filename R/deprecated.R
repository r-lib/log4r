#' @include logfuncs.R
NULL

#' Deprecated logger functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' * [create.logger()] and [logfile()] are deprecated in favour of [logger()].
#'   They issue deprecation warnings when used.
#'
#' * [debug()], [info()], [warn()], [error()], and [fatal()] are deprecated in
#'   favour of [log_debug()], [log_info()], [log_warn()], [log_error()], and
#'   [log_fatal()], respectively. For performance reasons they do not yet issue
#'   deprecation warnings when used.
#'
#' * [levellog()] is deprecated in favour of [log_at()]. It issues a deprecation
#'   warning when used.
#'
#' * [logformat()] is incompatible with **[Layouts][layouts]** and has been
#'   nonfunctional for many years. It issues a deprecation error when used.
#'
#' * [is.loglevel()], [as.loglevel()], its alias [loglevel()], and S3 generics
#'   for the `"loglevel"` class are now considered an implementation detail and
#'   are no longer part of the public API. They issue deprecation warnings when
#'   used.
#'
#' * [verbosity()] is similar, in that there is no longer a stable mapping
#'   between priority integers and levels. It issues a deprecation warning when
#'   used.
#'
#' @return [logformat()] and [logformat<-()] always throw an error. [logfile()]
#'   returns the path the logger writes to and [logfile<-()] returns the
#'   modified logger. The remaining functions return the same values as their
#'   replacements.
#'
#' @examples
#' # Deprecated: configure a logger with create.logger().
#' logger <- create.logger(logfile = tempfile(), level = "INFO")
#' info(logger, "A message.")
#'
#' # Instead, use logger() with an appender:
#' logger <- logger("INFO", appenders = file_appender(tempfile()))
#' log_info(logger, "A message.")
#' @export
#' @keywords internal
#' @rdname log4r-deprecated
create.logger <- function(
  logfile = "logfile.log",
  level = "FATAL",
  logformat = NULL
) {
  lifecycle::deprecate_warn("0.5.0", "create.logger()", "logger()")
  out <- logger(
    threshold = level,
    appenders = file_appender(file = logfile)
  )
  out$logfile <- logfile
  out
}

#' @rdname log4r-deprecated
#' @export
logfile <- function(x) {
  lifecycle::deprecate_warn("0.5.0", "logfile()", "logger()")
  UseMethod("logfile", x)
}

#' @rdname log4r-deprecated
#' @export
`logfile<-` <- function(x, value) {
  lifecycle::deprecate_warn("0.5.0", "logfile()", "logger()")
  UseMethod("logfile<-", x)
}

#' @rdname log4r-deprecated
#' @export
logfile.logger <- function(x) x$logfile

#' @rdname log4r-deprecated
#' @export
`logfile<-.logger` <- function(x, value) {
  # For loggers created with the old API, change the appender. Otherwise, do
  # nothing.
  if (!is.null(x$logfile)) {
    x$appenders <- list(file_appender(file = value))
    x$logfile <- value
  }
  x
}

#' @rdname log4r-deprecated
#' @export
logformat <- function(x) {
  lifecycle::deprecate_stop(
    "0.3.0",
    "logformat()",
    details = c(
      "x" = "It is incompatible with Layouts and has been nonfunctional for \\
      many years."
    )
  )
}

#' @rdname log4r-deprecated
#' @export
`logformat<-` <- function(x, value) {
  lifecycle::deprecate_stop(
    "0.3.0",
    "logformat()",
    details = c(
      "x" = "It is incompatible with Layouts and has been nonfunctional for \\
      many years."
    )
  )
}

#' @rdname log4r-deprecated
#' @export
is.loglevel <- function(x, ...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "is.loglevel()",
    details = c(
      "x" = "The internals of log levels are no longer part of the public API."
    )
  )
  inherits(x, "loglevel")
}

#' @rdname log4r-deprecated
#' @export
loglevel <- function(i) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "loglevel()",
    details = c(
      "x" = "The internals of log levels are no longer part of the public API."
    )
  )
  as_level(i)
}

#' @rdname log4r-deprecated
#' @export
as.loglevel <- function(i) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "as.loglevel()",
    details = c(
      "x" = "The internals of log levels are no longer part of the public API."
    )
  )
  as_level(i)
}

#' @rdname log4r-deprecated
#' @export
print.loglevel <- function(x, ...) {
  cat(LEVEL_NAMES[[x]], "\n")
}

#' @rdname log4r-deprecated
#' @export
as.numeric.loglevel <- function(x, ...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "as.numeric.loglevel()",
    details = c(
      "x" = "The internals of log levels are no longer part of the public API."
    )
  )
  unclass(unname(x))
}

#' @rdname log4r-deprecated
#' @export
as.character.loglevel <- function(x, ...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "as.character.loglevel()",
    details = c(
      "x" = "The internals of log levels are no longer part of the public API."
    )
  )
  LEVEL_NAMES[[x]]
}

#' @rdname log4r-deprecated
#' @export
verbosity <- function(v) {
  if (!is.numeric(v)) {
    stop("numeric expected")
  }
  lifecycle::deprecate_warn(
    "0.5.0",
    "verbosity()",
    details = c(
      "x" = "The internals of log levels are no longer part of the public API."
    )
  )
  as_level(length(LEVELS) + 1 - v)
}

#' @rdname log4r-deprecated
#' @export
levellog <- log_at

#' @rdname log4r-deprecated
#' @export
debug <- log_debug

#' @rdname log4r-deprecated
#' @export
info <- log_info

#' @rdname log4r-deprecated
#' @export
warn <- log_warn

#' @rdname log4r-deprecated
#' @export
error <- log_error

#' @rdname log4r-deprecated
#' @export
fatal <- log_fatal
