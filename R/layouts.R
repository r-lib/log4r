#' Format logs with Layouts
#'
#' @description
#'
#' In [log4j](https://logging.apache.org/log4j/) etymology, **Layouts** are how
#' **[Appenders][appenders]** control the format of messages. Most users will
#' use one of the general-purpose layouts provided by the package:
#'
#' * [default_log_layout()] formats messages much like the original log4j
#'   library. [simple_log_layout()] does the same, but omits the timestamp.
#'
#' * [bare_log_layout()] emits only the log message, with no level or timestamp
#'   fields.
#'
#' * [logfmt_log_layout()] and [json_log_layout()] format structured logs in the
#'   two most popular machine-readable formats.
#'
#' For implementing your own layouts, see Details.
#'
#' @details
#'
#' Layouts return a function with the signature `function(level, ...)` that
#' itself returns a single newline-terminated string. Anything that meets this
#' interface can be passed as a layout to one of the existing [appenders].
#'
#' @param time_format A valid format string for timestamps. See
#'   [base::strptime()].
#'
#' @examples
#' # The behaviour of a layout can be seen by using them directly:
#' simple <- simple_log_layout()
#' simple("INFO", "Input has length ", 0, ".")
#'
#' with_timestamp <- default_log_layout()
#' with_timestamp("INFO", "Input has length ", 0, ".")
#'
#' logfmt <- logfmt_log_layout()
#' logfmt("INFO", msg = "got input", length = 24)
#' @name layouts
#' @rdname layouts
#' @export
default_log_layout <- function(time_format = "%Y-%m-%d %H:%M:%S") {
  check_time_format(time_format)
  timestamp <- fmt_current_time(time_format, FALSE)

  function(level, ...) {
    msg <- paste0(..., collapse = "")
    sprintf("%-5s [%s] %s\n", level, timestamp(), msg)
  }
}

#' @rdname layouts
#' @aliases simple_log_layout
#' @export
simple_log_layout <- function() {
  function(level, ...) {
    msg <- paste0(..., collapse = "")
    sprintf("%-5s - %s\n", level, msg)
  }
}

#' @rdname layouts
#' @aliases bare_log_layout
#' @export
bare_log_layout <- function() {
  function(level, ...) {
    msg <- paste0(..., collapse = "")
    sprintf("%s\n", msg)
  }
}

#' @rdname layouts
#' @aliases logfmt_log_layout
#' @export
logfmt_log_layout <- function() {
  timestamp <- fmt_current_time("%Y-%m-%dT%H:%M:%OSZ", TRUE)

  function(level, ...) {
    fields <- list(...)
    if (is.null(names(fields))) {
      fields <- list(msg = paste0(fields, collapse = ""))
    }
    extra <- list(level = level, ts = timestamp())
    encode_logfmt(c(extra, fields))
  }
}

#' @details `json_log_layout` requires the `jsonlite` package.
#'
#' @rdname layouts
#' @aliases json_log_layout
#' @export
json_log_layout <- function() {
  rlang::check_installed("jsonlite", "to use this JSON layout.")
  timestamp <- fmt_current_time("%Y-%m-%dT%H:%M:%OSZ", TRUE)

  function(level, ...) {
    fields <- list(...)
    if (is.null(names(fields))) {
      fields <- list(message = paste0(fields, collapse = ""))
    }
    fields$level <- as.character(level)
    fields$time <- timestamp()
    sprintf("%s\n", jsonlite::toJSON(fields, auto_unbox = TRUE))
  }
}

# Given a strftime format string, return a fast function that outputs the
# current time in that format. This is about 1000x faster than using
# format(Sys.now()).
fmt_current_time <- function(format, use_utc = FALSE) {
  if (!grepl("%OS", format, fixed = TRUE)) {
    return(compiler::cmpfun(function() {
      .Call(R_fmt_current_time, format, use_utc, FALSE, NULL, PACKAGE = "log4r")
    }))
  }
  # If we need fractional seconds, break formatting into three pieces: (1) the
  # bit before %OS; (2) %S plus fractional seconds; and (3) the bit after %OS,
  # if any.
  split <- strsplit(format, "%OS[0-9]?")[[1]]
  prefix <- paste0(split[1], "%S")
  suffix <- NULL
  if (length(split) > 1) {
    suffix <- split[2]
  }
  compiler::cmpfun(function() {
    .Call(R_fmt_current_time, prefix, use_utc, TRUE, suffix, PACKAGE = "log4r")
  })
}

check_time_format <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (is.character(x)) {
    tryCatch(
      {
        fmt_current_time(x)()
        return(invisible(NULL))
      },
      error = function(e) {}
    )
  }
  cli::cli_abort(
    c(
      "{.arg {arg}} must be a valid timestamp format string.",
      "i" = "See {.help strptime} for details on available formats."
    ),
    call = call
  )
}

encode_logfmt <- function(fields) {
  .Call(R_encode_logfmt, fields, PACKAGE = "log4r")
}
