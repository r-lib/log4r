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
#> INFO  [2026-08-04 19:29:38] Info message.
cat_info()
#> INFO  [2026-08-04 19:29:38] Info message.
logging_info()
#> 2026-08-04 19:29:38.970228 INFO::Info message.
fl_info()
#> INFO [2026-08-04 19:29:38] Info message.
logger_info()
#> INFO [2026-08-04 19:29:38] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 19:29:38 [INFO] Info message.
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
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:39] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.
#> INFO [2026-08-04 19:29:40] Info message.

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
#>           expr     min       lq       mean    median        uq
#>          log4r  14.437   24.661   29.70764   26.5745   33.0770
#>            cat  25.588   32.941   42.32981   38.3820   45.6205
#>           rlog  46.447   63.659   73.71588   69.5395   76.2420
#>         logger 184.774  220.802  247.57244  230.1940  241.4605
#>        logging 323.243  368.047  403.78324  377.8890  398.9995
#>  futile.logger 475.878  536.135  566.19904  554.4340  571.9215
#>            lgr 988.263 1028.764 1175.13435 1041.3625 1059.2305
#>        max neval
#>    891.743   500
#>   1347.493   500
#>   1097.898   500
#>   2278.690   500
#>   6697.391   500
#>   2707.178   500
#>  32566.595   500
```

### How long does it take to decide to do nothing?

``` r

print(debug_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median       uq      max
#>            cat   1.954   2.6850   4.929864   3.6115   4.0270  716.266
#>          log4r   2.534   3.4970   5.917090   4.2030   4.9590  783.281
#>           rlog   6.852   8.4360  11.916638  10.4500  11.1860  753.034
#>            lgr  12.363  14.3565  18.575324  16.4705  17.5480  926.528
#>         logger  15.970  18.8205  23.959612  22.0210  24.1350  773.974
#>        logging  16.451  19.8070  25.867970  24.2050  25.9635  759.366
#>  futile.logger 202.228 211.4240 233.211038 216.9850 231.0210 2021.851
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
