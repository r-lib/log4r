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
#> INFO  [2026-08-04 18:43:51] Info message.
cat_info()
#> INFO  [2026-08-04 18:43:51] Info message.
logging_info()
#> 2026-08-04 18:43:51.793405 INFO::Info message.
fl_info()
#> INFO [2026-08-04 18:43:51] Info message.
logger_info()
#> INFO [2026-08-04 18:43:51] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 18:43:51 [INFO] Info message.
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
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:51] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.
#> INFO [2026-08-04 18:43:52] Info message.

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
#>           expr     min       lq      mean   median       uq       max
#>          log4r  10.325  17.9270  24.57009  21.0265  26.5845   691.666
#>            cat  17.666  22.6090  36.31622  27.9515  33.7600  2441.520
#>           rlog  29.864  43.1640  54.64675  49.9740  57.1695  1010.969
#>         logger 117.254 156.6175 201.23506 175.0190 189.8165  3382.906
#>        logging 212.284 260.5220 313.80341 278.0525 300.1000  4977.119
#>  futile.logger 333.584 400.6885 472.36851 427.4090 451.0540  6479.598
#>            lgr 681.871 738.4400 948.78992 763.8925 809.7310 23301.659
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```

### How long does it take to decide to do nothing?

``` r

print(debug_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median       uq      max
#>            cat   1.482   1.7975   3.385488   2.1685   2.4730  569.504
#>          log4r   1.843   2.2040   4.040102   2.6540   3.1850  601.391
#>           rlog   5.107   5.7785   7.978178   6.7705   7.5760  555.824
#>            lgr   9.143  10.1955  18.173194  11.3015  12.4085 2429.142
#>         logger  11.257  12.4385  15.677594  14.0760  15.8235  573.520
#>        logging  11.988  13.1290  16.714928  15.6030  17.2250  549.705
#>  futile.logger 140.058 147.5885 161.259100 151.2950 158.6605 2612.083
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
