test_that("Basic layouts work correctly", {
  layout <- simple_log_layout()
  expect_match(layout("INFO", "Message"), "Message")
  expect_match(
    layout("INFO", "Message ", "in a", " bottle."),
    "Message in a bottle."
  )

  layout <- default_log_layout()
  expect_match(layout("INFO", "Message"), "Message")
  expect_match(
    layout("INFO", "Message ", "in a", " bottle."),
    "Message in a bottle."
  )

  layout <- bare_log_layout()
  expect_match(layout("INFO", "Message"), "Message")
  expect_match(
    layout("INFO", "Message ", "in a", " bottle."),
    "Message in a bottle."
  )
})

test_that("logfmt layouts work correctly", {
  layout <- logfmt_log_layout()
  expect_match(layout("INFO", "Message"), 'msg=Message')
  expect_match(
    layout("INFO", a = "a", b = 1.2, c = 1L, d = TRUE, e = NULL, f = 1 + 3i),
    'a=a b=1.2 c=1 d=true e=null f=1\\+3i'
  )
  # Test escaping of keys and values.
  expect_match(layout("INFO", spaces = "with spaces"), 'spaces="with spaces"')
  expect_match(layout("INFO", "with spaces" = "value"), 'withspaces=value')
  # Test dropped keys.
  expect_false(grepl('value', layout("INFO", a = "a", "value")))
  expect_false(grepl('value', layout("INFO", " " = "value")))
  # Test precision.
  expect_match(layout("INFO", a = 1.234567, b = NULL), 'a=1.235 b=null')
  # Test dropped field values.
  expect_match(layout("INFO", a = 1:3, b = NULL), 'a=1 b=null')
  expect_match(
    layout("INFO", a = data.frame(a = 1:3), b = NULL),
    'a=<omitted> b=null'
  )
  # Test long keys and values.
  long <- paste(sample(c(letters, "="), 1019, TRUE), collapse = "")
  expect_match(layout("INFO", key = long), 'key=')
  expect_match(layout("INFO", long = "value"), '=value')
})

test_that("JSON layouts work correctly", {
  skip_if_not_installed("jsonlite")

  layout <- json_log_layout()
  expect_match(layout("INFO", "Message"), "\"message\":\"Message\"")
  expect_match(layout("INFO", field = "value"), "\"field\":\"value\"")
})

test_that("Wonky times formats are caught early", {
  expect_error(
    default_log_layout(strrep("%Y", 30)),
    regexp = "must be a valid timestamp format string"
  )
})
