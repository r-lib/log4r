# Send logs to their final destination with Appenders

In [log4j](https://logging.apache.org/log4j/) etymology, **Appenders**
are destinations where logs are written. Appenders have no control over
formatting; this is controlled by the
**[Layout](https://log4r.r-lib.org/dev/reference/layouts.md)**.

The most basic appenders write logs to the console or to a file; these
are described below.

For implementing your own appenders, see Details.

## Usage

``` r
console_appender(layout = default_log_layout())

file_appender(file, append = TRUE, layout = default_log_layout())
```

## Arguments

- layout:

  A layout function taking a `level` parameter and additional arguments
  corresponding to the message. See
  [`layouts()`](https://log4r.r-lib.org/dev/reference/layouts.md).

- file:

  The file to write messages to.

- append:

  When `TRUE`, the file is not truncated when opening for the first
  time.

## Value

An appender: a function with the interface `function(level, ...)` that
writes its arguments to a destination and returns `invisible(NULL)`.

## Details

Appenders are implemented as functions with the interface
`function(level, ...)`. These functions are expected to write their
arguments to a destination and return `invisible(NULL)`.

## See also

[`tcp_appender()`](https://log4r.r-lib.org/dev/reference/tcp_appender.md),
[`http_appender()`](https://log4r.r-lib.org/dev/reference/http_appender.md),
[`syslog_appender()`](https://log4r.r-lib.org/dev/reference/syslog_appender.md)

## Examples

``` r
# The behaviour of an appender can be seen by using them directly; the
# following snippet will write the message to the console.
appender <- console_appender()
appender("INFO", "Input has length ", 0, ".")
#> INFO  [2026-09-04 19:48:46] Input has length 0.
```
