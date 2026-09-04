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
#> INFO  [2026-09-04 19:48:52] Info message.
cat_info()
#> INFO  [2026-09-04 19:48:52] Info message.
logging_info()
#> 2026-09-04 19:48:52.32146 INFO::Info message.
fl_info()
#> INFO [2026-09-04 19:48:52] Info message.
logger_info()
#> INFO [2026-09-04 19:48:52] Info message.
lgr_info()
rlog_info()
#> 2026-09-04 19:48:52 [INFO] Info message.
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
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:52] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.
#> INFO [2026-09-04 19:48:53] Info message.

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
#>           expr     min        lq       mean    median        uq
#>          log4r  14.266   24.3855   29.52801   26.5995   33.0615
#>            cat  25.638   32.7110   41.83937   38.2415   45.3000
#>           rlog  46.357   62.6415   71.68230   68.2080   76.2880
#>         logger 180.557  217.9015  233.63031  227.7105  238.8210
#>        logging 320.578  367.0800  401.85986  377.7305  396.9210
#>  futile.logger 480.146  537.1280  560.98487  557.0150  573.7310
#>            lgr 981.402 1025.7400 1169.18342 1041.2040 1059.9090
#>        max neval
#>    902.405   500
#>   1302.372   500
#>   1101.837   500
#>   1842.169   500
#>   6797.821   500
#>   2557.395   500
#>  32435.035   500
```

### How long does it take to decide to do nothing?

``` r

print(debug_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median       uq      max
#>            cat   1.943   2.7050   4.994764   3.6270   4.0470  754.629
#>          log4r   2.555   3.3815   6.032838   4.1630   4.9145  830.851
#>           rlog   6.883   8.4355  11.571084  10.3540  11.0555  753.377
#>            lgr  12.423  14.5570  21.950378  16.6565  17.6580 1808.487
#>         logger  16.050  19.0050  23.613552  22.0565  24.0050  774.155
#>        logging  16.731  20.1180  25.291466  24.1700  25.7835  772.954
#>  futile.logger 205.103 211.7200 227.346256 217.3960 232.5845 2048.224
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
