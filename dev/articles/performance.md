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
#> INFO  [2026-08-04 22:53:20] Info message.
cat_info()
#> INFO  [2026-08-04 22:53:20] Info message.
logging_info()
#> 2026-08-04 22:53:20.759796 INFO::Info message.
fl_info()
#> INFO [2026-08-04 22:53:20] Info message.
logger_info()
#> INFO [2026-08-04 22:53:20] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 22:53:20 [INFO] Info message.
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
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:20] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:21] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.
#> INFO [2026-08-04 22:53:22] Info message.

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
#>           expr     min       lq       mean   median       uq       max
#>          log4r  13.039  22.0175   28.54022  25.7635  32.4340   870.853
#>            cat  23.005  27.8870   37.24480  32.6690  41.4620  1253.019
#>           rlog  38.227  53.8950   64.72410  61.9115  70.8650  1220.291
#>         logger 142.521 197.2430  229.60751 216.0655 230.6825  2523.365
#>        logging 260.977 325.3025  363.50042 347.5860 365.3220  6350.634
#>  futile.logger 418.211 495.3400  535.89021 527.4180 552.0495  2949.086
#>            lgr 851.865 921.3830 1078.01596 947.4860 974.4960 29090.378
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
#>           expr     min       lq       mean   median      uq      max
#>            cat   1.913   2.2435   4.159012   2.6535   3.064  687.080
#>          log4r   2.393   2.7290   4.942958   3.2800   3.906  771.145
#>           rlog   6.520   7.2405   9.976212   8.4520   9.434  738.076
#>            lgr  11.787  12.6140  16.637796  14.2265  15.443 1059.833
#>         logger  14.341  15.4835  19.300332  17.1405  19.539  712.878
#>        logging  14.992  16.3790  20.861416  19.0780  21.162  700.760
#>  futile.logger 173.347 184.3585 205.803144 190.3470 200.848 2678.595
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
