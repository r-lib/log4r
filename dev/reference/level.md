# Set the logging threshold level for a logger dynamically

It can sometimes be useful to change the logging threshold level at
runtime. The `level()` accessor allows doing so.

## Usage

``` r
level(x)

level(x) <- value

# S3 method for class 'logger'
level(x)

# S3 method for class 'logger'
level(x) <- value

available.loglevels()
```

## Arguments

- x:

  An object of class `"logger"`.

- value:

  One of `"DEBUG"`, `"INFO"`, `"WARN"`, `"ERROR"`, or `"FATAL"`.

## Value

`level()` returns the logger's threshold and `level<-()` returns the
modified logger. `available.loglevels()` returns a named list of all
thresholds.

## Examples

``` r
lgr <- logger()
level(lgr) # Prints "INFO".
#> INFO 
info(lgr, "This message is shown.")
#> INFO  [2026-08-04 19:59:30] This message is shown.
level(lgr) <- "FATAL"
info(lgr, "This message is now suppressed.")
```
