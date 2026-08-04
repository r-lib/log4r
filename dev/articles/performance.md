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
#> INFO  [2026-08-04 18:45:30] Info message.
cat_info()
#> INFO  [2026-08-04 18:45:30] Info message.
logging_info()
#> 2026-08-04 18:45:30.90102 INFO::Info message.
fl_info()
#> INFO [2026-08-04 18:45:30] Info message.
logger_info()
#> INFO [2026-08-04 18:45:30] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 18:45:30 [INFO] Info message.
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
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:31] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.
#> INFO [2026-08-04 18:45:32] Info message.

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
#>           expr      min        lq       mean    median        uq
#>          log4r   14.687   25.5070   31.46922   27.7420   34.5700
#>            cat   27.131   33.7575   51.55601   40.0700   47.9150
#>           rlog   47.008   64.6060   85.43177   71.5535   79.2780
#>         logger  185.136  223.2975  259.84086  235.5345  256.4990
#>        logging  325.448  373.5175  422.78633  389.4420  411.6885
#>  futile.logger  488.562  554.5605  602.85433  576.9470  597.7315
#>            lgr 1007.421 1046.2040 1226.91259 1060.4100 1085.9980
#>        max neval
#>    954.803   500
#>   3585.646   500
#>   4503.830   500
#>   2752.179   500
#>   7103.404   500
#>   1700.065   500
#>  33195.305   500
```

### How long does it take to decide to do nothing?

``` r

print(debug_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median       uq      max
#>            cat   1.924   2.5950   5.062534   3.6360   4.0775  794.213
#>          log4r   2.545   3.3160   6.100044   4.2335   5.0695  852.802
#>           rlog   6.983   8.6160  12.283082  10.9000  11.6820  738.649
#>            lgr  12.493  14.5125  25.038784  16.9820  18.1990 2836.897
#>         logger  15.870  18.8400  24.542766  22.6170  24.6760  776.470
#>        logging  16.461  19.8620  26.098318  24.5855  26.6445  779.436
#>  futile.logger 208.840 216.9100 243.228740 222.2950 241.3055 2968.362
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
