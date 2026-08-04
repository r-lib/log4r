# Send logs over HTTP

Send logs in the body of HTTP requests. Responses with status code 400
or above will trigger errors.

Requires the `httr` package.

## Usage

``` r
http_appender(url, method = "POST", layout = default_log_layout(), ...)
```

## Arguments

- url:

  The URL to submit messages to.

- method:

  The HTTP method to use, usually `"POST"` or `"GET"`.

- layout:

  A layout function taking a `level` parameter and additional arguments
  corresponding to the message.

- ...:

  Further arguments passed on to
  [`httr::POST()`](https://httr.r-lib.org/reference/POST.html).

## Value

An appender: a function with the interface `function(level, ...)` that
submits its arguments to `url` and returns `invisible(NULL)`.

## See also

[appenders](https://log4r.r-lib.org/dev/reference/appenders.md) for more
information on Appenders.

## Examples

``` r
if (FALSE) { # \dontrun{
# POST messages to localhost.
appender <- http_appender("localhost")
appender("INFO", "Message.")

# POST JSON-encoded messages.
appender <- http_appender(
  "localhost", method = "POST", layout = default_log_layout(),
  httr::content_type_json()
)
appender("INFO", "Message.")
} # }
```
