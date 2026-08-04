# Create a logger

This is the main interface for configuring logging behaviour. We adopt
the well-known [log4j](https://logging.apache.org/log4j/) etymology:
**[Appenders](https://log4r.r-lib.org/dev/reference/appenders.md)** are
destinations (e.g. the console or a file) where logs are written, and
the **[Layout](https://log4r.r-lib.org/dev/reference/layouts.md)** is
the format of these logs.

## Usage

``` r
logger(threshold = "INFO", appenders = console_appender())
```

## Arguments

- threshold:

  The logging threshold, one of `"DEBUG"`, `"INFO"`, `"WARN"`,
  `"ERROR"`, or `"FATAL"`. Logs with a lower severity than the threshold
  will be discarded.

- appenders:

  The logging appenders; both single appenders and a
  [`list()`](https://rdrr.io/r/base/list.html) of them are supported.
  See
  **[Appenders](https://log4r.r-lib.org/dev/reference/appenders.md)**.

## Value

An object of class `"logger"`.

## See also

**[Appenders](https://log4r.r-lib.org/dev/reference/appenders.md)** and
**[Layouts](https://log4r.r-lib.org/dev/reference/layouts.md)** for
information on controlling the behaviour of the logger object.

## Examples

``` r
# By default, logs are written to the console at the "INFO" threshold.
logger <- logger()

log_info(logger, "Located nearest gas station.")
#> INFO  [2026-08-04 22:53:16] Located nearest gas station.
log_warn(logger, "Ez-Gas sensor network is not available.")
#> WARN  [2026-08-04 22:53:16] Ez-Gas sensor network is not available.
log_debug(logger, "Debug messages are suppressed by default.")
```
