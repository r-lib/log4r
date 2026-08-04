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
#> INFO  [2026-08-04 19:26:10] Info message.
cat_info()
#> INFO  [2026-08-04 19:26:10] Info message.
logging_info()
#> 2026-08-04 19:26:10.50745 INFO::Info message.
fl_info()
#> INFO [2026-08-04 19:26:10] Info message.
logger_info()
#> INFO [2026-08-04 19:26:10] Info message.
lgr_info()
rlog_info()
#> 2026-08-04 19:26:10 [INFO] Info message.
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
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:10] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.
#> INFO [2026-08-04 19:26:11] Info message.

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
#>          log4r  14.137   24.4710   29.33652   26.4445   32.5105
#>            cat  24.565   32.7060   41.69367   37.8200   45.2795
#>           rlog  46.918   62.3415   70.68905   68.2670   74.7945
#>         logger 176.650  214.8700  237.74967  224.4190  233.9610
#>        logging 314.506  359.3150  388.12802  369.2285  386.5710
#>  futile.logger 466.039  527.4840  548.02612  544.4600  560.9810
#>            lgr 949.381 1007.1285 1139.37348 1018.5850 1030.8630
#>        max neval
#>    894.569   500
#>   1296.569   500
#>   1104.220   500
#>   1975.014   500
#>   6715.707   500
#>   2263.822   500
#>  31446.065   500
```

### How long does it take to decide to do nothing?

``` r

print(debug_bench, order = "median")
#> Unit: microseconds
#>           expr     min       lq       mean   median       uq      max
#>            cat   1.854   2.5895   4.746268   3.4720   3.9575  716.477
#>          log4r   2.364   3.3315   5.766632   4.0530   4.7840  798.620
#>           rlog   6.352   8.1150  11.038048   9.7830  10.7400  745.341
#>            lgr  11.512  13.9210  17.777222  15.7440  17.1420  952.156
#>         logger  14.718  18.2845  22.760098  21.0495  23.1630  739.038
#>        logging  15.398  19.4015  24.126330  23.0130  24.9110  736.003
#>  futile.logger 188.652 207.6470 223.099442 212.5120 222.6655 1806.620
#>  neval
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
#>    500
```
