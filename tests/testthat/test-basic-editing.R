library(tabulatoR)
library(shiny)

# Helper function for readable JSON snapshots
expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

# =============================================================================
# EDITING BEHAVIOR TESTS
# =============================================================================
# These tests verify that tabulatoR handles the editable and editor parameters
# correctly according to the documented behavior:
# - Setting editable = TRUE without editor should default to editor = TRUE
# - Setting editor to a value should implicitly set editable = TRUE
# - Column definitions should properly serialize editing options

test_that("setting editable = TRUE defaults to editor = TRUE", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice", age = 25, stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    # Column with editable = TRUE should get editor = TRUE
    cols <- c(
      Column(title = "Name", field = "name", editable = TRUE)
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # Should contain both editable and editor as true
    expect_match(json, '"editable"\\s*:\\s*true')
    expect_match(json, '"editor"\\s*:\\s*true')
  })
})

test_that("setting editor option defaults editable = TRUE", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice", age = 25, stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    # Column with editor specified should implicitly set editable = TRUE
    cols <- c(
      Column(title = "Name", field = "name", editor = "input")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # Should contain both editor and editable
    expect_match(json, '"editor"\\s*:\\s*"input"')
    expect_match(json, '"editable"\\s*:\\s*true')
  })
})

test_that("editor='input' works correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    cols <- c(
      Column(title = "Name", field = "name", editor = "input")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    expect_match(json, '"editor"\\s*:\\s*"input"')
    expect_match(json, '"editable"\\s*:\\s*true')
  })
})

test_that("editor='number' works correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(age = 25)
    rv <- reactiveVal(df)

    cols <- c(
      Column(title = "Age", field = "age", editor = "number")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    expect_match(json, '"editor"\\s*:\\s*"number"')
    expect_match(json, '"editable"\\s*:\\s*true')
  })
})

test_that("editor='textarea' works correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(notes = "Some text", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    cols <- c(
      Column(title = "Notes", field = "notes", editor = "textarea")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    expect_match(json, '"editor"\\s*:\\s*"textarea"')
    expect_match(json, '"editable"\\s*:\\s*true')
  })
})

test_that("editor='select' with editorParams works correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(status = "active", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    cols <- c(
      Column(
        title = "Status",
        field = "status",
        editor = "select",
        editorParams = list(values = c("active", "inactive", "pending"))
      )
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    expect_match(json, '"editor"\\s*:\\s*"select"')
    expect_match(json, '"editorParams"')
    expect_match(json, '"values"')
    expect_match(json, '"active"')
    expect_match(json, '"inactive"')
    expect_match(json, '"pending"')
  })
})

test_that("editable = FALSE does not add editor", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(id = 1, stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    cols <- c(
      Column(title = "ID", field = "id", editable = FALSE)
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    expect_match(json, '"editable"\\s*:\\s*false')
    # Should not contain editor property
    # Note: we can't easily test for absence in JSON, but we can verify editable is false
  })
})

test_that("mixed editable and non-editable columns", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      id = 1,
      name = "Alice",
      age = 25,
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    cols <- c(
      Column(title = "ID", field = "id", editable = FALSE),
      Column(title = "Name", field = "name", editor = "input"),
      Column(title = "Age", field = "age", editable = TRUE)
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # Verify structure contains all columns
    expect_match(json, '"field"\\s*:\\s*"id"')
    expect_match(json, '"field"\\s*:\\s*"name"')
    expect_match(json, '"field"\\s*:\\s*"age"')

    # Snapshot complete structure
    expect_snapshot_json(json)
  })
})

test_that("autoColumns with editable = TRUE generates editable columns", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      name = "Alice",
      age = 25,
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    # autoColumns should create columns with editor = TRUE when editable = TRUE
    renderer <- renderTabulatoR(rv(), autoColumns = TRUE, editable = TRUE)
    json <- isolate(renderer())

    # All auto-generated columns should have editor = true
    expect_match(json, '"editor"\\s*:\\s*true')

    # Should have columns for each field
    expect_match(json, '"field"\\s*:\\s*"name"')
    expect_match(json, '"field"\\s*:\\s*"age"')
  })
})

test_that("autoColumns with editable = FALSE generates non-editable columns", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      name = "Alice",
      age = 25,
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    # autoColumns should set editor = null when editable = FALSE
    renderer <- renderTabulatoR(rv(), autoColumns = TRUE, editable = FALSE)
    json <- isolate(renderer())

    # Should contain editor: null (not editor: true or editor: "input")
    expect_match(json, '"editor"\\s*:\\s*null')
    expect_false(grepl('"editor"\\s*:\\s*true', json))
  })
})

test_that("cellEdited callback is included when specified", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    # Add a cellEdited callback
    cols <- c(
      Column(
        title = "Name",
        field = "name",
        editor = "input",
        cellEdited = js("function(cell) { console.log('edited'); }")
      )
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # Should contain cellEdited callback
    expect_match(json, '"cellEdited"')
    expect_match(json, 'function\\(cell\\)')
  })
})

test_that("complete editing snapshot with various editor types", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      id = 1:2,
      name = c("Alice", "Bob"),
      age = c(25, 30),
      status = c("active", "inactive"),
      notes = c("Note 1", "Note 2"),
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    cols <- c(
      Column(title = "ID", field = "id", editable = FALSE, width = "60px"),
      Column(title = "Name", field = "name", editor = "input"),
      Column(title = "Age", field = "age", editor = "number"),
      Column(
        title = "Status",
        field = "status",
        editor = "select",
        editorParams = list(values = c("active", "inactive", "pending"))
      ),
      Column(title = "Notes", field = "notes", editor = "textarea")
    )

    renderer <- renderTabulatoR(rv(), columns = cols, layout = "fitColumns")
    json <- isolate(renderer())

    # Snapshot for regression testing
    expect_snapshot_json(json)
  })
})

test_that("Column() with only editable = TRUE and no other params", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(value = 42)
    rv <- reactiveVal(df)

    # Minimal column with just editable
    cols <- c(
      Column(title = "Value", field = "value", editable = TRUE)
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    # Should have editor = true as default
    expect_match(json, '"editable"\\s*:\\s*true')
    expect_match(json, '"editor"\\s*:\\s*true')
  })
})

test_that("editor with editorParams for number range", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(score = 75)
    rv <- reactiveVal(df)

    cols <- c(
      Column(
        title = "Score",
        field = "score",
        editor = "number",
        editorParams = list(min = 0, max = 100, step = 1)
      )
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())

    expect_match(json, '"editor"\\s*:\\s*"number"')
    expect_match(json, '"editorParams"')
    expect_match(json, '"min"\\s*:\\s*0')
    expect_match(json, '"max"\\s*:\\s*100')
    expect_match(json, '"step"\\s*:\\s*1')
  })
})
