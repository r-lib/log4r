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
#> INFO  [2026-08-04 22:51:45] Info message.
cat_info()
#> INFO  [2026-08-04 22:51:45] Info message.
logging_info()
#> 2026-08-04 22:51:45.288525 INFO::Info message.
fl_info()
#> INFO [2026-08-04 22:51:45] Info message.
logger_info()
#> INFO [2026-08-04 22:51:45] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 22:51:45 [INFO] Info message.
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
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:45] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.
#> INFO [2026-08-04 22:51:46] Info message.

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
#>          log4r  13.110  21.4720   27.56239  25.2480  31.5570   879.068
#>            cat  22.854  28.0370   37.14363  33.0690  41.3360  1222.489
#>           rlog  37.226  52.5980   63.30895  60.9760  69.6940  1171.924
#>         logger 148.321 193.2220  226.56932 216.7470 230.7880  2454.892
#>        logging 264.333 319.9660  356.75632 344.5730 360.2010  6181.576
#>  futile.logger 413.666 494.9820  527.71194 525.4565 546.4030  2897.951
#>            lgr 850.626 917.0145 1067.31924 941.6310 964.0395 28535.941
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
#>            cat   1.903   2.2285   4.052566   2.6440   3.0400  687.353
#>          log4r   2.404   2.7040   4.828284   3.2300   3.8655  721.524
#>           rlog   6.560   7.1560   9.845758   8.4225   9.3140  688.985
#>            lgr  11.548  12.4785  16.371230  13.9260  15.3830 1049.121
#>         logger  14.361  15.3480  19.206184  17.0800  19.3440  710.206
#>        logging  15.052  16.0940  20.451482  18.9430  21.0015  693.772
#>  futile.logger 175.821 183.2630 204.206524 188.8160 199.6620 2676.301
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
