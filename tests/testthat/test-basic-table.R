library(tabulatoR)
library(shiny)

# Helper function for readable JSON snapshots
expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

# =============================================================================
# NATIVE TABULATOR VS TABULATORO COMPARISON
# =============================================================================
# These tests verify that tabulatoR generates JSON structures compatible with
# native Tabulator.js initialization.
#
# NOTE: tabulatoR uses jsonlite::toJSON() with auto_unbox=TRUE to serialize data,
# producing clean JSON without unnecessary array wrapping (e.g., {"a": 1} not {"a": [1]}).
# This matches native Tabulator.js expectations and eliminates the need for client-side
# unwrapping that was previously required with htmlwidgets:::toJSON2().

test_that("tabulatoR JSON payload structure matches Tabulator expectations", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    # Simple test data
    df <- data.frame(
      name = c("Alice", "Bob"),
      age = c(25, 30),
      stringsAsFactors = FALSE
    )

    # Generate tabulatoR output
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv(), autoColumns = FALSE)
    json <- isolate(renderer())

    # Native Tabulator.js initialization:
    # new Tabulator(el, {
    #   data: [{name: "Alice", age: 25}, {name: "Bob", age: 30}],
    #   autoColumns: true
    # })
    #
    # tabulatoR now generates this exact format directly

    # Verify JSON contains key elements
    expect_type(json, "character")
    expect_match(json, '"options"')
    expect_match(json, '"data"')
    expect_match(json, '"Alice"')
    expect_match(json, '"Bob"')
    expect_match(json, '25')
    expect_match(json, '30')
    expect_match(json, '"autoColumns"\\s*:\\s*true')
  })
})

test_that("tabulatoR column definitions produce valid Tabulator column config", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(id = 1:2, name = c("Alice", "Bob"), stringsAsFactors = FALSE)

    # Native Tabulator columns:
    # columns: [
    #   {title: "ID", field: "id", width: "50px", hozAlign: "center"},
    #   {title: "Name", field: "name", editor: "input"}
    # ]

    rv <- reactiveVal(df)
    cols <- c(
      Column(title = "ID", field = "id", width = "50px", hozAlign = "center"),
      Column(title = "Name", field = "name", editor = "input")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # Verify column properties are in JSON
    expect_match(json, '"title"\\s*:\\s*"ID"')
    expect_match(json, '"field"\\s*:\\s*"id"')
    expect_match(json, '"width"\\s*:\\s*"50px"')
    expect_match(json, '"hozAlign"\\s*:\\s*"center"')
    expect_match(json, '"title"\\s*:\\s*"Name"')
    expect_match(json, '"field"\\s*:\\s*"name"')
    expect_match(json, '"editor"\\s*:\\s*"input"')
  })
})

test_that("tabulatoR options serialize correctly for Tabulator", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:10)

    # Native Tabulator options:
    # new Tabulator(el, {
    #   data: [...],
    #   layout: "fitData",
    #   pagination: true,
    #   paginationSize: 5
    # })

    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(
      rv(),
      layout = "fitData",
      pagination = TRUE,
      paginationSize = 5
    )
    json <- isolate(renderer())

    # Verify options in JSON
    expect_match(json, '"layout"\\s*:\\s*"fitData"')
    expect_match(json, '"pagination"\\s*:\\s*true')
    expect_match(json, '"paginationSize"\\s*:\\s*5')
  })
})

test_that("tabulatoR scalars serialize as scalars not arrays", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv(), layout = "fitColumns", pagination = FALSE)
    json <- isolate(renderer())

    # Scalars should not be wrapped in arrays
    expect_match(json, '"layout"\\s*:\\s*"fitColumns"')
    expect_false(grepl('"layout"\\s*:\\s*\\["fitColumns"\\]', json))

    expect_match(json, '"pagination"\\s*:\\s*false')
    expect_false(grepl('"pagination"\\s*:\\s*\\[false\\]', json))
  })
})

test_that("tabulatoR data arrays serialize as JSON arrays", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = "x", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())

    # Data should be an array (starts with '[')
    expect_match(json, '"data"\\s*:\\s*\\[')

    # Columns should be an array (starts with '[')
    expect_match(json, '"columns"\\s*:\\s*\\[')
  })
})

test_that("complete table snapshot matches expected Tabulator-compatible format", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    # Create a realistic table
    df <- data.frame(
      id = 1:3,
      name = c("Alice", "Bob", "Charlie"),
      age = c(25, 30, 35),
      stringsAsFactors = FALSE
    )

    # Define columns similar to native Tabulator
    cols <- c(
      Column(title = "ID", field = "id", width = "60px", hozAlign = "center"),
      Column(title = "Name", field = "name", editor = "input"),
      Column(title = "Age", field = "age", hozAlign = "right", editor = "number")
    )

    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(
      rv(),
      columns = cols,
      layout = "fitColumns"
    )
    json <- isolate(renderer())

    # Snapshot the complete output for regression testing
    expect_snapshot_json(json)
  })
})

test_that("minimal table produces valid Tabulator-compatible output", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    # Minimal native Tabulator:
    # new Tabulator(el, {data: [{a: 1}, {a: 2}]})

    df <- data.frame(a = 1:2)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())

    # Snapshot for regression
    expect_snapshot_json(json)
  })
})

test_that("tabulatoR preserves data types through JSON serialization", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    # Test various R types
    df <- data.frame(
      int_col = 1L,
      num_col = 1.5,
      char_col = "text",
      bool_col = TRUE,
      stringsAsFactors = FALSE
    )

    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())

    # Values are NOT wrapped in arrays, types are preserved as JSON primitives
    # Numbers should not be quoted
    expect_match(json, ':\\s*1[,}]')  # integer unwrapped
    expect_match(json, ':\\s*1\\.5')  # double unwrapped

    # Strings should be quoted
    expect_match(json, '"text"')

    # Booleans should not be quoted
    expect_match(json, ':\\s*true')  # boolean unwrapped
  })
})

test_that("empty table generates valid Tabulator config", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    # Empty native Tabulator:
    # new Tabulator(el, {
    #   data: [],
    #   columns: [{title: "A", field: "a"}]
    # })

    df <- data.frame(a = integer(), stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())

    # Note: split() on empty data.frame creates rows with empty vectors
    # This is a quirk of the current implementation
    # The JSON should still be valid
    expect_silent(jsonlite::fromJSON(json))

    # Should have data array (even if empty rows)
    expect_match(json, '"data"')

    # Should have column definition
    expect_match(json, '"columns"')
  })
})

test_that("tabulatoR payload has correct top-level structure", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should have options and events at top level
    expect_true("options" %in% names(payload))
    expect_true("events" %in% names(payload))

    # options should contain Tabulator config
    expect_true("data" %in% names(payload$options))
    expect_true("columns" %in% names(payload$options))
    expect_true("layout" %in% names(payload$options))
  })
})

test_that("multiple columns combine correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = 2, c = 3)
    rv <- reactiveVal(df)

    # Combine columns like native Tabulator columns array
    cols <- c(
      Column("A", "a"),
      Column("B", "b"),
      Column("C", "c")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # All columns should be present
    expect_match(json, '"field"\\s*:\\s*"a"')
    expect_match(json, '"field"\\s*:\\s*"b"')
    expect_match(json, '"field"\\s*:\\s*"c"')
  })
})

test_that("layout option defaults to fitColumns like Tabulator", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())

    # Default layout should be fitColumns
    expect_match(json, '"layout"\\s*:\\s*"fitColumns"')
  })
})

test_that("custom layout option overrides default", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv(), layout = "fitData")
    json <- isolate(renderer())

    # Should use custom layout
    expect_match(json, '"layout"\\s*:\\s*"fitData"')
  })
})
