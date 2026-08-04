# Logging Beyond Local Files

For local development or simple batch R scripts run manually, writing
log messages to a file for later inspection (with `file_appender`) is
quite convenient. However, for deployed R applications (like Shiny apps
and Plumber APIs) or automated scripts it is more likely that all an
organization’s logs will be aggregated in one central place (perhaps
with a commercial tool or service[^1]) for searching and monitoring. It
can be annoying or impossible to upload log files in these cases.

If your organization’s platform supports reading log messages from
regular program output,[^2] you can just use the default setup, which
uses the
[`console_appender()`](https://log4r.r-lib.org/reference/appenders.md).
Otherwise, **log4r** includes three additional appenders to facilitate
shipping logs off to an aggregator:

- `syslog_appender`: For writing messages to the system log on Linux,
  macOS, and other Unix-like operating systems.

- `http_appender`: For sending log messages as HTTP requests.

- `tcp_appender`: For writing log messages to TCP connections.

## Writing to the System Log

The Unix “System log” (syslog) dates to the mid-1980s, and is still
widely used. Almost all log aggregation services support ingesting a
server’s syslog messages, so often the easiest way to get your logs to
these services is to make your R talk to the local syslog.

To use the `syslog_appender`, all you need is an identifier for your R
app or script:

``` r

logger <- logger(appenders = syslog_appender("my-R-script"))
```

Requires the [**rsyslog**](https://cran.r-project.org/package=rsyslog)
package.

## Sending Logs over HTTP

If you’re not already forwarding syslog messages (or need to send logs
from Windows), the next most-common approach is to send them over HTTP.
Log aggregation services usually provide an HTTP API endpoint to
facilitate this:

``` r

logger <- logger(appenders = http_appender("https://logging.example.local"))
```

Some services use `GET` or `PUT` requests instead of the more intuitive
`POST`, which you can opt into as follows:

``` r

logger <- logger(
  appenders = http_appender("https://logging.example.local", method = "GET")
)
```

Finally, if you need complete control over the HTTP request (for
example, to send a specific header or use authentication), you can pass
additional parameters to the underlying **httr** verb function:

``` r

logger <- logger(
  appenders = http_appender(
    "https://logging.example.local",
    method = "GET",
    layout = default_log_layout(),
    httr::add_headers(`X-Custom-Header` = 1),
    httr::user_agent("my-r-script/1.0.0")
  )
)
```

Requires the [**httr**](https://cran.r-project.org/package=httr)
package.

## Writing Directly to TCP Connections

For some workloads, the send-and-receive structure of HTTP requests may
be undesirable, so many log aggregators also accept messages directly at
a TCP port:

``` r

logger <- logger(
  appenders = tcp_appender("tcp://logging.example.local", port = 9551)
)
```

[^1]: Such as [Splunk](https://www.splunk.com/) or
    [Loggly](https://www.loggly.com/solution/log-management/). There are
    also many open-source options, such as the [ELK
    Stack](https://www.elastic.co/elastic-stack/) or
    [Graylog](https://graylog.org/).

[^2]: For example, when running as a Docker container in a cluster with
    all logs forwarded automatically, or when scripts are wrapped up as
    SystemD unit files.
