# Deprecated logger functions

**\[deprecated\]**

- `create.logger()` and `logfile()` are deprecated in favour of
  [`logger()`](https://log4r.r-lib.org/dev/reference/logger.md). They
  issue deprecation warnings when used.

- `debug()`, `info()`, `warn()`, `error()`, and `fatal()` are deprecated
  in favour of
  [`log_debug()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  [`log_info()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  [`log_warn()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  [`log_error()`](https://log4r.r-lib.org/dev/reference/log_at.md), and
  [`log_fatal()`](https://log4r.r-lib.org/dev/reference/log_at.md),
  respectively. For performance reasons they do not yet issue
  deprecation warnings when used.

- `levellog()` is deprecated in favour of
  [`log_at()`](https://log4r.r-lib.org/dev/reference/log_at.md). It
  issues a deprecation warning when used.

- `logformat()` is incompatible with
  **[Layouts](https://log4r.r-lib.org/dev/reference/layouts.md)** and
  has been nonfunctional for many years. It issues a deprecation error
  when used.

- `is.loglevel()`, `as.loglevel()`, its alias `loglevel()`, and S3
  generics for the `"loglevel"` class are now considered an
  implementation detail and are no longer part of the public API. They
  issue deprecation warnings when used.

- `verbosity()` is similar, in that there is no longer a stable mapping
  between priority integers and levels. It issues a deprecation warning
  when used.

## Usage

``` r
create.logger(logfile = "logfile.log", level = "FATAL", logformat = NULL)

logfile(x)

logfile(x) <- value

# S3 method for class 'logger'
logfile(x)

# S3 method for class 'logger'
logfile(x) <- value

logformat(x)

logformat(x) <- value

is.loglevel(x, ...)

loglevel(i)

as.loglevel(i)

# S3 method for class 'loglevel'
print(x, ...)

# S3 method for class 'loglevel'
as.numeric(x, ...)

# S3 method for class 'loglevel'
as.character(x, ...)

verbosity(v)

levellog(logger, level, ...)

debug(logger, ...)

info(logger, ...)

warn(logger, ...)

error(logger, ...)

fatal(logger, ...)
```
