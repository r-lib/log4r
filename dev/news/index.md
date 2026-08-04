# Changelog

## log4r 0.4.4.9000

- [`logfmt_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  and
  [`json_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  now use timestamps with microsecond precision, when possible.

- [`debug()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  [`info()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  [`warn()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  [`error()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  and
  [`fatal()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md)
  are deprecated in favour of the newly-exported
  [`log_debug()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  [`log_info()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  [`log_warn()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  [`log_error()`](https://log4r.r-lib.org/dev/reference/log_at.md), and
  [`log_fatal()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  respectively, though for performance reasons they do not yet issue
  deprecation warnings when used. These older functions tended to cause
  namespace issues with other packages or base R itself
  ([\#29](https://github.com/johnmyleswhite/log4r/issues/29)).

- Much of the pre-0.3.0 logger API is now formally deprecated and issues
  warnings when used. This includes
  [`create.logger()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md)
  and
  [`logfile()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md).

- [`is.loglevel()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  [`as.loglevel()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  its alias
  [`loglevel()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md),
  and S3 generics for the `"loglevel"` class are now considered an
  implementation detail and are no longer part of the public API. They
  now issue deprecation warnings when used. Hopefully this makes way for
  adding a `TRACE` level and corresponding `log_trace()` function in the
  future. The obscure
  [`verbosity()`](https://log4r.r-lib.org/dev/reference/log4r-deprecated.md)
  function is also now deprecated, for similar reasons.

- Errors have been migrated to
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  and are now much friendlier and actionable as a result.

## log4r 0.4.4

CRAN release: 2024-10-12

- Fixes failing unit tests for the HTTP appender.

- JSON logs now have newlines, as intended
  ([\#30](https://github.com/johnmyleswhite/log4r/issues/30),
  [@brooklynbagel](https://github.com/brooklynbagel)).

- Updates the R CMD check GitHub Action to a modern version
  ([\#27](https://github.com/johnmyleswhite/log4r/issues/27),
  [@hadley](https://github.com/hadley)).

- Updates the project to `testthat` 3e
  ([\#26](https://github.com/johnmyleswhite/log4r/issues/26),
  [@hadley](https://github.com/hadley)).

- Updates `roxygen2` documentation to use Markdown syntax
  ([\#25](https://github.com/johnmyleswhite/log4r/issues/25),
  [@hadley](https://github.com/hadley)).

## log4r 0.4.3

CRAN release: 2022-11-28

- Fixes a potential memory corruption issue identified by rchk. Thanks
  to Tomas Kalibera for the associated patch.

## log4r 0.4.2

CRAN release: 2021-11-04

- Fixes a crash where
  [`logfmt_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  would not correctly handle memory reallocation of the underlying
  buffer.

## log4r 0.4.1

CRAN release: 2021-10-28

- Fixes a crash when the
  [`logfmt_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  is passed long fields that also need escaping.

- [`logfmt_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  now drops fields with missing names rather than writing `NA`, which
  matches the existing handling of other empty/unrepresentable field
  names.

## log4r 0.4.0

CRAN release: 2021-10-26

- Support for structured logging by passing additional named parameters
  to the existing logging functions. This includes two new
  structured-logging layouts for JSON and
  [logfmt](https://brandur.org/logfmt) and a vignette on using them:
  “Structured Logging”.

- New built-in appenders for writing to the Unix system log, via HTTP,
  and to TCP connections, plus a vignette on using them: “Logging Beyond
  Local Files”.

- A new
  [`bare_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  for when you don’t want the level or timestamp handled automatically.
  This is most useful for the
  [`syslog_appender()`](https://log4r.r-lib.org/dev/reference/syslog_appender.md).

- Log messages prior to the last entry are no longer lost when a file
  appender is created with `append = FALSE`. Instead, the file is
  truncated only when the appender is created, as intended. Fixes
  [\#17](https://github.com/johnmyleswhite/log4r/issues/17).

## log4r 0.3.2 (2020-01-17)

CRAN release: 2020-01-18

- Fixes an issue where appender functions did not evaluate all their
  arguments, leading to surprising behaviour in e.g. loops. Reported by
  Nicola Farina.

## log4r 0.3.1 (2019-09-04)

CRAN release: 2019-09-04

- There is now a vignette on logger performance.
- Fixes a missing header file on older versions of R (\<= 3.4).
  ([\#12](https://github.com/johnmyleswhite/log4r/issues/12))
- Fixes an issue where
  [`default_log_layout()`](https://log4r.r-lib.org/dev/reference/layouts.md)
  would not validate format strings correctly.

## log4r 0.3.0 (2019-06-20)

CRAN release: 2019-06-21

- A new system for configuring logging, via “Appenders” and “Layouts”.
  See [`?logger`](https://log4r.r-lib.org/dev/reference/logger.md),
  [`?appenders`](https://log4r.r-lib.org/dev/reference/appenders.md),
  and [`?layouts`](https://log4r.r-lib.org/dev/reference/layouts.md) for
  details.
- Various fixes and performance improvements.
- New maintainer: Aaron Jacobs (<atheriel@gmail.com>)

## log4r 0.2 (2014-09-29)

CRAN release: 2014-09-29

- Same as v0.1-5.

## log4r 0.1-5 (2014-09-28)

- New maintainer: Kirill Müller (<krlmlr+r@mailbox.org>)
- Log levels are now objects of class `"loglevel"`, access to the hidden
  constants, e.g., `log4r:::DEBUG`, is deprecated
  ([\#4](https://github.com/johnmyleswhite/log4r/issues/4)).
