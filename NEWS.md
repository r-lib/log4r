# log4r 0.5.0

# log4r 0.4.4.9000

* `logfmt_log_layout()` and `json_log_layout()` now use timestamps with
  microsecond precision, when possible.

* `debug()`, `info()`, `warn()`, `error()`, and `fatal()` are deprecated in
  favour of the newly-exported `log_debug()`, `log_info()`, `log_warn()`,
  `log_error()`, and `log_fatal()`, respectively, though for performance reasons
  they do not yet issue deprecation warnings when used. These older functions
  tended to cause namespace issues with other packages or base R itself (#29).

* Much of the pre-0.3.0 logger API is now formally deprecated and issues
  warnings when used. This includes `create.logger()` and `logfile()`.

* `is.loglevel()`, `as.loglevel()`, its alias `loglevel()`, and S3 generics for
  the `"loglevel"` class are now considered an implementation detail and are no
  longer part of the public API. They now issue deprecation warnings when used.
  Hopefully this makes way for adding a `TRACE` level and corresponding
  `log_trace()` function in the future. The obscure `verbosity()` function is
  also now deprecated, for similar reasons.

* Errors have been migrated to `cli::cli_abort()` and are now much friendlier
  and actionable as a result.

# log4r 0.4.4

* Fixes failing unit tests for the HTTP appender.

* JSON logs now have newlines, as intended (#30, @brooklynbagel).

* Updates the R CMD check GitHub Action to a modern version (#27, @hadley).

* Updates the project to `testthat` 3e (#26, @hadley).

* Updates `roxygen2` documentation to use Markdown syntax (#25, @hadley).

# log4r 0.4.3

* Fixes a potential memory corruption issue identified by rchk. Thanks to Tomas
  Kalibera for the associated patch.

# log4r 0.4.2

* Fixes a crash where `logfmt_log_layout()` would not correctly handle memory
  reallocation of the underlying buffer.

# log4r 0.4.1

* Fixes a crash when the `logfmt_log_layout()` is passed long fields that also
  need escaping.

* `logfmt_log_layout()` now drops fields with missing names rather than writing
  `NA`, which matches the existing handling of other empty/unrepresentable field
  names.

# log4r 0.4.0

* Support for structured logging by passing additional named parameters to the
  existing logging functions. This includes two new structured-logging layouts
  for JSON and [logfmt](https://brandur.org/logfmt) and a vignette on using
  them: "Structured Logging".

* New built-in appenders for writing to the Unix system log, via HTTP, and to
  TCP connections, plus a vignette on using them: "Logging Beyond Local Files".

* A new `bare_log_layout()` for when you don't want the level or timestamp
  handled automatically. This is most useful for the `syslog_appender()`.

* Log messages prior to the last entry are no longer lost when a file appender
  is created with `append = FALSE`. Instead, the file is truncated only when the
  appender is created, as intended. Fixes #17.

# log4r 0.3.2 (2020-01-17)

* Fixes an issue where appender functions did not evaluate all their arguments,
  leading to surprising behaviour in e.g. loops. Reported by Nicola Farina.

# log4r 0.3.1 (2019-09-04)

* There is now a vignette on logger performance.
* Fixes a missing header file on older versions of R (<= 3.4). (#12)
* Fixes an issue where `default_log_layout()` would not validate format strings
  correctly.

# log4r 0.3.0 (2019-06-20)

* A new system for configuring logging, via "Appenders" and "Layouts". See
  `?logger`, `?appenders`, and `?layouts` for details.
* Various fixes and performance improvements.
* New maintainer: Aaron Jacobs (atheriel@gmail.com)

# log4r 0.2 (2014-09-29)

* Same as v0.1-5.

# log4r 0.1-5 (2014-09-28)

* New maintainer: Kirill Müller (krlmlr+r@mailbox.org)
* Log levels are now objects of class `"loglevel"`, access to the hidden
  constants, e.g., `log4r:::DEBUG`, is deprecated (#4).
