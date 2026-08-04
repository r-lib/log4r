test_that("The console appender works correctly", {
  appender <- console_appender(simple_log_layout())
  expect_output(appender("Message"), "Message")
})

test_that("The file appender works correctly", {
  outfile <- tempfile("log")
  appender <- file_appender(outfile, layout = simple_log_layout())

  expect_silent(appender("Message"))
  expect_file_contains(outfile, regex = "Message")
})

test_that("The HTTP appender works correctly", {
  skip_if_not_installed("httr")
  httpbin <- webfakes::local_app_process(webfakes::httpbin_app())

  appender <- http_appender(
    httpbin$url("/post"), layout = simple_log_layout()
  )
  expect_silent(appender("INFO", "Message"))

  appender <- expect_silent(http_appender(
    httpbin$url("/post"),
    method = "POST",
    layout = bare_log_layout(),
    httr::content_type_json()
  ))
  expect_silent(appender("INFO", '{"message":"Message"}'))
})

test_that("The HTTP appender errors on HTTP error statuses", {
  skip_if_not_installed("httr")
  skip_if_not_installed("webfakes")

  httpbin <- webfakes::local_app_process(webfakes::httpbin_app())

  appender <- http_appender(
    httpbin$url("/status/503"), layout = simple_log_layout()
  )
  expect_snapshot(appender("INFO", "Message"), error = TRUE)
})

test_that("The HTTP appender accepts only valid verbs", {
  skip_if_not_installed("httr")

  expect_error(
    http_appender("http://httpbin.org/post", method = "INVALID"),
    regex = "not a supported HTTP method"
  )
})

test_that("Layout arguments are checked", {
  expect_error(console_appender("notalayout"))
  expect_error(file_appender(tempfile("log"), layout = "notalayout"))
  expect_error(tcp_appender(layout = "notalayout"))

  skip_if_not_installed("httr")
  expect_error(http_appender(layout = "notalayout"))

  skip_if_not_installed("rsyslog")
  expect_error(syslog_appender(layout = "notalayout"))
})

test_that("The syslog appender works correctly", {
  skip_if_not_installed("rsyslog")

  appender <- syslog_appender("myapp")

  # Don't send actual syslog messages on CRAN.
  skip_on_cran()
  expect_silent(appender("INFO", "Message"))
})

test_that("Messages from the syslog appender end up in the system log", {
  skip_if_not_installed("rsyslog")
  skip_on_cran()

  if (nchar(Sys.which("journalctl")) == 0) {
    skip("No 'journalctl' available to check syslog messages.")
  }

  journal <- system2(
    "journalctl", c("-rq", "-t", "myapp"), stdout = TRUE, stderr = FALSE
  )

  if (!is.null(attr(journal, "status"))) {
    skip("'journalctl' command failed, likely due to a permissions issue.")
  }

  expect_true(any(
    grepl(paste0("myapp[", Sys.getpid(), "]"), journal, fixed = TRUE)
  ))
})

test_that("Lazy evaluation does not lead to surprising results", {
  x <- "foo.txt"
  y <- TRUE
  appender <- file_appender(file = x, append = y)
  x <- "bar.txt"
  y <- FALSE

  # Check that mutating the parent environment does not modify them in the
  # frame in which the appender evaluates.
  expect_equal(environment(appender)$file, "foo.txt")
  expect_equal(environment(appender)$append, TRUE)
})
