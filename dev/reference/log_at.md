# Write logs at a given level

Write logs at a given level

## Usage

``` r
log_at(logger, level, ...)

log_debug(logger, ...)

log_info(logger, ...)

log_warn(logger, ...)

log_error(logger, ...)

log_fatal(logger, ...)
```

## Arguments

- logger:

  An object of class `"logger"`.

- level:

  The desired severity, one of `"DEBUG"`, `"INFO"`, `"WARN"`, `"ERROR"`,
  or `"FATAL"`. Messages with a lower severity than the logger threshold
  will be discarded.

- ...:

  One or more items to log.

## Value

`invisible(NULL)`, called for the side effect of writing to the logger's
appenders.

## Examples

``` r
logger <- logger()

log_at(logger, "WARN", "First warning from our code")
#> WARN  [2026-09-04 19:48:47] First warning from our code
log_debug(logger, "Debugging our code")
log_info(logger, "Information about our code")
#> INFO  [2026-09-04 19:48:47] Information about our code
log_warn(logger, "Another warning from our code")
#> WARN  [2026-09-04 19:48:47] Another warning from our code
log_error(logger, "An error from our code")
#> ERROR [2026-09-04 19:48:47] An error from our code
log_fatal(logger, "I'm outta here")
#> FATAL [2026-09-04 19:48:47] I'm outta here
```
