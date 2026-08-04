# Package index

## Basics

- [`logger()`](https://log4r.r-lib.org/reference/logger.md) : Create a
  logger
- [`log_at()`](https://log4r.r-lib.org/reference/log_at.md)
  [`log_debug()`](https://log4r.r-lib.org/reference/log_at.md)
  [`log_info()`](https://log4r.r-lib.org/reference/log_at.md)
  [`log_warn()`](https://log4r.r-lib.org/reference/log_at.md)
  [`log_error()`](https://log4r.r-lib.org/reference/log_at.md)
  [`log_fatal()`](https://log4r.r-lib.org/reference/log_at.md) : Write
  logs at a given level

## Appenders

- [`console_appender()`](https://log4r.r-lib.org/reference/appenders.md)
  [`file_appender()`](https://log4r.r-lib.org/reference/appenders.md) :
  Send logs to their final destination with Appenders
- [`syslog_appender()`](https://log4r.r-lib.org/reference/syslog_appender.md)
  : Send logs to the local syslog
- [`http_appender()`](https://log4r.r-lib.org/reference/http_appender.md)
  : Send logs over HTTP
- [`tcp_appender()`](https://log4r.r-lib.org/reference/tcp_appender.md)
  : Send logs over TCP

## Layouts

- [`default_log_layout()`](https://log4r.r-lib.org/reference/layouts.md)
  [`simple_log_layout()`](https://log4r.r-lib.org/reference/layouts.md)
  [`bare_log_layout()`](https://log4r.r-lib.org/reference/layouts.md)
  [`logfmt_log_layout()`](https://log4r.r-lib.org/reference/layouts.md)
  [`json_log_layout()`](https://log4r.r-lib.org/reference/layouts.md) :
  Format logs with Layouts

## Advanced

- [`level()`](https://log4r.r-lib.org/reference/level.md)
  [`` `level<-`() ``](https://log4r.r-lib.org/reference/level.md)
  [`available.loglevels()`](https://log4r.r-lib.org/reference/level.md)
  : Set the logging threshold level for a logger dynamically
