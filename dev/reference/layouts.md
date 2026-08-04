# Format logs with Layouts

In [log4j](https://logging.apache.org/log4j/) etymology, **Layouts** are
how **[Appenders](https://log4r.r-lib.org/dev/reference/appenders.md)**
control the format of messages. Most users will use one of the
general-purpose layouts provided by the package:

- `default_log_layout()` formats messages much like the original log4j
  library. `simple_log_layout()` does the same, but omits the timestamp.

- `bare_log_layout()` emits only the log message, with no level or
  timestamp fields.

- `logfmt_log_layout()` and `json_log_layout()` format structured logs
  in the two most popular machine-readable formats.

For implementing your own layouts, see Details.

## Usage

``` r
default_log_layout(time_format = "%Y-%m-%d %H:%M:%S")

simple_log_layout()

bare_log_layout()

logfmt_log_layout()

json_log_layout()
```

## Arguments

- time_format:

  A valid format string for timestamps. See
  [`base::strptime()`](https://rdrr.io/r/base/strptime.html).

## Value

A layout: a function with the interface `function(level, ...)` that
returns a single newline-terminated string.

## Details

Layouts return a function with the signature `function(level, ...)` that
itself returns a single newline-terminated string. Anything that meets
this interface can be passed as a layout to one of the existing
[appenders](https://log4r.r-lib.org/dev/reference/appenders.md).

`json_log_layout` requires the `jsonlite` package.

## Examples

``` r
# The behaviour of a layout can be seen by using them directly:
simple <- simple_log_layout()
simple("INFO", "Input has length ", 0, ".")
#> [1] "INFO  - Input has length 0.\n"

with_timestamp <- default_log_layout()
with_timestamp("INFO", "Input has length ", 0, ".")
#> [1] "INFO  [2026-08-04 19:59:30] Input has length 0.\n"

logfmt <- logfmt_log_layout()
logfmt("INFO", msg = "got input", length = 24)
#> [1] "level=INFO ts=2026-08-04T19:59:30.660036Z msg=\"got input\" length=24\n"
```
