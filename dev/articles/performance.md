# Logging Performance

The following vignette presents benchmarks for **log4r** against all
general-purpose logging packages available on CRAN:

- [**futile.logger**](https://cran.r-project.org/package=futile.logger)
  and [**logging**](https://cran.r-project.org/package=logging), which
  are well-established packages; and
- [**logger**](https://cran.r-project.org/package=logger),
  [**lgr**](https://cran.r-project.org/package=lgr), and
  [**rlog**](https://cran.r-project.org/package=rlog), all of which are
  relative newcomers.

Each logging package features slightly different capabilities, but these
benchmarks are focused on the two situations common to using all of
them:

1.  Logging simple messages to the console; and
2.  Deciding not to log a message because it is below the threshold.

The first of these is likely the most common kind of logging done by end
users, although some may chose to log to files, over HTTP, or to the
[system log](https://cran.r-project.org/package=rsyslog) (among others).
Yet a benchmark of these other scenarios would largely show the relative
expense of these operations, instead of the overhead of the logic
performed by the logging packages themselves.

The second measures the performance impact of leaving logging messages
in running code, even if they are below the current threshold of
visibility. This is another measure of overhead for each logging
package.

## Using `cat()`

As a reference point, we can measure how long it takes R itself to write
a simple message to the console:

``` r

cat_debug <- function() {
  cat() # Print nothing.
}

cat_info <- function() cat(
  "INFO  [", format(Sys.time(), "%Y-%m-%d %H:%M:%S", usetz = FALSE),
  "] Info message.", sep = ""
)
```

## The **log4r** Package

The following is a typical **log4r** setup:

``` r

log4r_logger <- log4r::logger(threshold = "INFO")

log4r_info <- function() {
  log4r::log_info(log4r_logger, "Info message.")
}

log4r_debug <- function() {
  log4r::log_debug(log4r_logger, "Debug message.")
}
```

## The **futile.logger** Package

The following is a typical **futile.logger** setup:

``` r

requireNamespace("futile.logger")
#> Loading required namespace: futile.logger

futile.logger::flog.logger()

fl_info <- function() {
  futile.logger::flog.info("Info message.")
}

fl_debug <- function() {
  futile.logger::flog.debug("Debug message.")
}
```

## The **logging** Package

The following is what I believe to be a typical **logging** setup:

``` r

requireNamespace("logging")
#> Loading required namespace: logging

logging::basicConfig()

logging_info <- function() {
  logging::loginfo("Info message.")
}

logging_debug <- function() {
  logging::logdebug("Debug message.")
}
```

## The **logger** Package

The following is what I believe to be a typical **logger** setup:

``` r

requireNamespace("logger")
#> Loading required namespace: logger
#> Registered S3 method overwritten by 'logger':
#>   method         from 
#>   print.loglevel log4r

# Match the behaviour of other logging packages and write to the console.
logger::log_appender(logger::appender_stdout)

logger_info <- function() {
  logger::log_info("Info message.")
}

logger_debug <- function() {
  logger::log_debug("Debug message.")
}
```

## The **lgr** Package

The following is what I believe to be a typical **lgr** setup:

``` r

requireNamespace("lgr")
#> Loading required namespace: lgr

lgr_logger <- lgr::get_logger("perf-test")
lgr_logger$set_appenders(list(cons = lgr::AppenderConsole$new()))
lgr_logger$set_propagate(FALSE)

lgr_info <- function() {
  lgr_logger$info("Info message.")
}

lgr_debug <- function() {
  lgr_logger$debug("Debug message.")
}
```

## The **rlog** Package

The **rlog** package currently has no configuration options other than
the threshold, which is controlled via an environment variable and
defaults to hiding debug-level messages:

``` r

requireNamespace("rlog")
#> Loading required namespace: rlog

rlog_info <- function() {
  rlog::log_info("Info message.")
}

rlog_debug <- function() {
  rlog::log_debug("Debug message.")
}
```

## Test All Loggers

Debug messages should print nothing.

``` r

log4r_debug()
cat_debug()
logging_debug()
fl_debug()
logger_debug()
lgr_debug()
rlog_debug()
```

Info messages should print to the console. Small differences in output
format are to be expected.

``` r

log4r_info()
#> INFO  [2026-08-04 19:59:36] Info message.
cat_info()
#> INFO  [2026-08-04 19:59:36] Info message.
logging_info()
#> 2026-08-04 19:59:36.501212 INFO::Info message.
fl_info()
#> INFO [2026-08-04 19:59:36] Info message.
logger_info()
#> INFO [2026-08-04 19:59:36] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 19:59:36 [INFO] Info message.
```

## Benchmarks

The following benchmarks all loggers defined above:

``` r

info_bench <- microbenchmark::microbenchmark(
  cat = cat_info(),
  log4r = log4r_info(),
  futile.logger = fl_info(),
  logging = logging_info(),
  logger = logger_info(),
  lgr = lgr_info(),
  rlog = rlog_info(),
  times = 500,
  control = list(warmups = 50)
)
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:36] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.
#> INFO [2026-08-04 19:59:37] Info message.

debug_bench <- microbenchmark::microbenchmark(
  cat = cat_debug(),
  log4r = log4r_debug(),
  futile.logger = fl_debug(),
  logging = logging_debug(),
  logger = logger_debug(),
  lgr = lgr_debug(),
  rlog = rlog_debug(),
  times = 500,
  control = list(warmups = 50)
)
```

### How long does it take to print messages?

``` r

print(info_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median        uq
#>          log4r  13.320  22.0730   29.79074  26.6840   34.0500
#>            cat  23.074  28.3620   38.42839  33.5645   42.2320
#>           rlog  38.006  54.7460   66.14464  63.7145   72.7170
#>         logger 151.544 197.8520  241.93532 222.4340  245.8090
#>        logging 269.238 330.4685  375.40704 356.9280  381.0990
#>  futile.logger 429.866 510.0095  561.10568 546.3530  576.9635
#>            lgr 863.457 942.7445 1138.19188 969.9395 1003.0435
#>        max neval
#>    887.482   500
#>   1478.106   500
#>   1403.104   500
#>   2959.476   500
#>   6557.658   500
#>   3522.480   500
#>  39721.791   500
```

### How long does it take to decide to do nothing?

``` r

print(debug_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median       uq      max
#>            cat   1.873   2.2935   4.329638   2.6840   3.0950  698.153
#>          log4r   2.394   2.7890   5.045084   3.3550   3.9905  770.099
#>           rlog   6.570   7.4460  10.276788   8.6930   9.8345  696.079
#>            lgr  11.938  12.8740  17.317398  14.7270  15.9385 1173.575
#>         logger  14.662  15.9685  20.040478  17.9915  20.2350  736.730
#>        logging  15.303  16.6645  21.444014  19.7795  21.8375  742.799
#>  futile.logger 181.518 190.5720 213.934298 196.2255 206.6305 3386.478
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
