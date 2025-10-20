library(tabulatoR)

# Test basic JS() functionality
test_that("JS() creates a JS object", {
  js_code <- "function(cell) { return cell.getValue() * 2; }"
  result <- JS(js_code)

  expect_s3_class(result, "JS_EVAL")
  expect_type(result, "character")
})

test_that("JS() works with Column formatter", {
  col <- Column(
    title = "Price",
    field = "price",
    formatter = JS("function(cell) { return '$' + cell.getValue(); }")
  )

  expect_true(inherits(col[[1]]$formatter, "JS_EVAL"))
})

test_that("JS() works with Column cellClick", {
  col <- Column(
    title = "Name",
    field = "name",
    cellClick = JS("function(e, cell) { alert(cell.getValue()); }")
  )

  expect_true(inherits(col[[1]]$cellClick, "JS_EVAL"))
})

test_that("JS() works with Column editor", {
  col <- Column(
    title = "Name",
    field = "name",
    editor = JS("function(cell, onRendered, success, cancel) { /* custom */ }")
  )

  expect_true(inherits(col[[1]]$editor, "JS_EVAL"))
})

# Test serialization with renderTabulatoR
test_that("JS() serializes correctly in renderTabulatoR", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(price = c(10, 20, 30)))

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Price",
          field = "price",
          formatter = JS("function(cell) { return '$' + cell.getValue(); }")
        )
      )
    )

    json <- shiny::isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # The formatter should be serialized as a string
    expect_type(payload$options$columns[[1]]$formatter, "character")

    # The formatter should contain the JavaScript code
    expect_match(payload$options$columns[[1]]$formatter, "function\\(cell\\)")
    expect_match(payload$options$columns[[1]]$formatter, "getValue")
  })
})

# Test that JS() works in nested structures
test_that("JS() works in formatterParams", {
  col <- Column(
    title = "Name",
    field = "name",
    formatter = "link",
    formatterParams = list(
      labelField = "name",
      urlPrefix = "http://",
      target = "_blank",
      onClick = JS("function(e, cell) { console.log('clicked'); }")
    )
  )

  expect_true(inherits(col[[1]]$formatterParams$onClick, "JS_EVAL"))
})

# Test that JS() works in events
test_that("JS() works in custom event handlers", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(a = 1))

    renderer <- renderTabulatoR(
      rv(),
      events = list(
        cellClick = JS("function(e, cell) { return { custom: true }; }")
      )
    )

    json <- shiny::isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_true("cellClick" %in% names(payload$events))
    expect_type(payload$events$cellClick, "character")
    expect_match(payload$events$cellClick, "function")
  })
})

# Test backwards compatibility with js()
test_that("js() is an alias for JS()", {
  code <- "function() { return true; }"

  result_JS <- JS(code)
  result_js <- js(code)

  expect_equal(class(result_JS), class(result_js))
  expect_equal(as.character(result_JS), as.character(result_js))
})

# Test error handling
test_that("JS() requires a character string", {
  expect_error(JS(123), "character")
  expect_error(JS(NULL), "character")
  expect_error(JS(list()), "character")
})

# Test that JS() output can be recognized by JavaScript
test_that("JS() output contains markers for JavaScript detection", {
  result <- JS("function() { return 42; }")
  char_result <- as.character(result)

  # Should contain the JavaScript code
  expect_match(char_result, "function.*return 42")

  # Should have some way for JS to detect it (either tags or class)
  # This is implementation-dependent, but we need SOME marker
  expect_true(
    grepl("<js>", char_result) || inherits(result, "JS_EVAL"),
    info = "JS() must provide a way for JavaScript to identify code strings"
  )
})

# Integration test with ActionColumn
test_that("ActionColumn formatter is JS compatible", {
  col <- ActionColumn("Edit", "edit")

  # ActionColumn uses js() internally, which should now be JS()
  expect_true(inherits(col[[1]]$formatter, "JS_EVAL"))
})
