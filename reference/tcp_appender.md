# Send logs over TCP

Append messages to arbitrary TCP destinations.

## Usage

``` r
tcp_appender(
  host,
  port,
  layout = default_log_layout(),
  timeout = getOption("timeout")
)
```

## Arguments

- host:

  Hostname for the socket connection.

- port:

  Port number for the socket connection.

- layout:

  A layout function taking a `level` parameter and additional arguments
  corresponding to the message.

- timeout:

  Timeout for the connection.

## Value

An appender: a function with the interface `function(level, ...)` that
writes its arguments to the socket and returns `invisible(NULL)`.

## See also

[appenders](https://log4r.r-lib.org/reference/appenders.md) for more
information on Appenders, and
[`base::socketConnection()`](https://rdrr.io/r/base/connections.html)
for the underlying connection object used by `tcp_appender()`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Send messages to a listener on localhost.
appender <- tcp_appender("localhost", port = 8080)
appender("INFO", "Message.")
} # }
```
