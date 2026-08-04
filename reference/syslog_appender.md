# Send logs to the local syslog

Send messages to the local syslog. Requires the `rsyslog` package.

## Usage

``` r
syslog_appender(identifier, layout = bare_log_layout(), ...)
```

## Arguments

- identifier:

  A string identifying the application.

- layout:

  A layout function taking a `level` parameter and additional arguments
  corresponding to the message.

- ...:

  Further arguments passed on to
  [`rsyslog::open_syslog()`](https://rdrr.io/pkg/rsyslog/man/syslog.html).

## Value

An appender: a function with the interface `function(level, ...)` that
writes its arguments to the local syslog and returns `invisible(NULL)`.

## See also

[appenders](https://log4r.r-lib.org/reference/appenders.md) for more
information on Appenders.

## Examples

``` r
if (FALSE) { # \dontrun{
# Send messages to the local syslog.
appender <- syslog_appender("my-application")
appender("INFO", "Message.")
} # }
```
