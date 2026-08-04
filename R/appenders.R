#' Send logs to their final destination with Appenders
#'
#' @description
#'
#' In [log4j](https://logging.apache.org/log4j/) etymology, **Appenders** are
#' destinations where logs are written. Appenders have no control over
#' formatting; this is controlled by the **[Layout][layouts]**.
#'
#' The most basic appenders write logs to the console or to a file; these are
#' described below.
#'
#' For implementing your own appenders, see Details.
#'
#' @details
#'
#' Appenders are implemented as functions with the interface `function(level,
#' ...)`. These functions are expected to write their arguments to a destination
#' and return `invisible(NULL)`.
#'
#' @param layout A layout function taking a `level` parameter and additional
#'   arguments corresponding to the message. See [layouts()].
#'
#' @examples
#' # The behaviour of an appender can be seen by using them directly; the
#' # following snippet will write the message to the console.
#' appender <- console_appender()
#' appender("INFO", "Input has length ", 0, ".")
#' @seealso [tcp_appender()], [http_appender()], [syslog_appender()]
#' @name appenders
#' @rdname appenders
#' @export
console_appender <- function(layout = default_log_layout()) {
  file_appender(file = "", layout = layout)
}

#' @param file The file to write messages to.
#' @param append When `TRUE`, the file is not truncated when opening for
#'   the first time.
#'
#' @rdname appenders
#' @export
file_appender <- function(file, append = TRUE, layout = default_log_layout()) {
  check_layout(layout)
  layout <- compiler::cmpfun(layout)
  force(file)
  if (!append) {
    # This should truncate the file, if it exists.
    file.create(file)
  }
  function(level, ...) {
    msg <- layout(level, ...)
    cat(msg, file = file, sep = "", append = TRUE)
  }
}

#' Send logs over TCP
#'
#' Append messages to arbitrary TCP destinations.
#'
#' @param host Hostname for the socket connection.
#' @param port Port number for the socket connection.
#' @param layout A layout function taking a `level` parameter and
#'   additional arguments corresponding to the message.
#' @param timeout Timeout for the connection.
#'
#' @seealso [appenders] for more information on Appenders, and
#'   [base::socketConnection()] for the underlying connection object
#'   used by [tcp_appender()].
#'
#' @export
tcp_appender <- function(
  host,
  port,
  layout = default_log_layout(),
  timeout = getOption("timeout")
) {
  check_layout(layout)
  layout <- compiler::cmpfun(layout)
  # Use a finalizer pattern to make sure we close the connection.
  env <- new.env(size = 1)
  env$con <- socketConnection(
    host = host,
    port = port,
    open = "wb",
    blocking = TRUE,
    timeout = timeout
  )
  reg.finalizer(env, function(e) close(e$con), onexit = TRUE)
  function(level, ...) {
    msg <- layout(level, ...)
    writeBin(msg, con = env$con)
  }
}

#' Send logs over HTTP
#'
#' @description
#'
#' Send logs in the body of HTTP requests. Responses with status code 400
#' or above will trigger errors.
#'
#' Requires the `httr` package.
#'
#' @param url The URL to submit messages to.
#' @param method The HTTP method to use, usually `"POST"` or `"GET"`.
#' @param layout A layout function taking a `level` parameter and
#'   additional arguments corresponding to the message.
#' @param ... Further arguments passed on to [httr::POST()].
#'
#' @examples
#' \dontrun{
#' # POST messages to localhost.
#' appender <- http_appender("localhost")
#' appender("INFO", "Message.")
#'
#' # POST JSON-encoded messages.
#' appender <- http_appender(
#'   "localhost", method = "POST", layout = default_log_layout(),
#'   httr::content_type_json()
#' )
#' appender("INFO", "Message.")
#' }
#' @seealso [appenders] for more information on Appenders.
#'
#' @export
http_appender <- function(
  url,
  method = "POST",
  layout = default_log_layout(),
  ...
) {
  rlang::check_installed("httr", "to use this HTTP appender.")
  check_layout(layout)
  layout <- compiler::cmpfun(layout)

  tryCatch(
    {
      verb <- get(method, envir = asNamespace("httr"))
    },
    error = function(e) {
      cli::cli_abort("{.str {method}} is not a supported HTTP method.")
    }
  )
  args <- c(list(url = url), list(...))
  function(level, ...) {
    args$body <- layout(level, ...)
    resp <- do.call(verb, args)

    # Treat HTTP errors as actual errors.
    if (httr::status_code(resp) >= 400) {
      cli::cli_abort(
        "Server responded with status {.code {httr::status_code(resp)}}."
      )
    }
  }
}

#' Send logs to the local syslog
#'
#' Send messages to the local syslog. Requires the `rsyslog` package.
#'
#' @param identifier A string identifying the application.
#' @param layout A layout function taking a `level` parameter and
#'   additional arguments corresponding to the message.
#' @param ... Further arguments passed on to [rsyslog::open_syslog()].
#'
#' @seealso [appenders] for more information on Appenders.
#'
#' @export
syslog_appender <- function(identifier, layout = bare_log_layout(), ...) {
  rlang::check_installed("rsyslog", "to use this syslog appender.")
  check_layout(layout)
  layout <- compiler::cmpfun(layout)

  rsyslog::open_syslog(identifier = identifier, ...)

  # Override any existing masking. Priority thresholds are handled by the
  # package instead of by syslog.
  rsyslog::set_syslog_mask("DEBUG")

  function(level, ...) {
    msg <- layout(level, ...)
    # Translate between log4j and syslog priority levels. Using a switch
    # statement turns out to be faster than a lookup.
    syslog_level <- switch(
      level,
      "TRACE" = "DEBUG",
      "DEBUG" = "DEBUG",
      "INFO" = "INFO",
      "WARN" = "WARNING",
      "ERROR" = "ERR",
      "FATAL" = "CRITICAL"
    )
    rsyslog::syslog(msg, level = syslog_level)
  }
}

check_layout <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (is.function(x)) {
    return(invisible(NULL))
  }
  cli::cli_abort("{.arg {arg}} must be a function.", call = call)
}
