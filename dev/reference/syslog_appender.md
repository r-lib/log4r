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

## See also

[appenders](https://log4r.r-lib.org/dev/reference/appenders.md) for more
information on Appenders.
