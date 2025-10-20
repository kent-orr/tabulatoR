library(tabulatoR)
library(shiny)
library(testthat)

# =============================================================================
# SHINY EDITING TESTS
# =============================================================================
# These tests verify that interactive editing features work correctly in Shiny,
# including cell edits, row additions/deletions, and event handling.

test_that("cellEdited event structure can be simulated", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactiveVal(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column("Name", "name", editor = "input"),
        Column("Age", "age", editor = "number")
      )
    )

    # Verify renderer creates editable columns
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true(any(sapply(payload$options$columns, function(col) !is.null(col$editor))))
  })
})

test_that("editable columns have correct configuration", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column("Name", "name", editor = "input"),
        Column("Age", "age", editor = "number")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Verify column editors
    expect_equal(payload$options$columns[[1]]$editor, "input")
    expect_equal(payload$options$columns[[2]]$editor, "number")
  })
})

test_that("non-editable columns work correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column("ID", "id", editable = FALSE),
        Column("Name", "name", editor = "input")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # First column should not be editable
    expect_equal(payload$options$columns[[1]]$editable, FALSE)

    # Second column should be editable
    expect_true(!is.null(payload$options$columns[[2]]$editor))
  })
})

test_that("default cellEdited event handler is configured", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(Column("Name", "name", editor = "input"))
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Default events should be present (or NULL/empty if using defaults in JS)
    # This test verifies the payload structure allows events
    expect_true("events" %in% names(payload))
  })
})

test_that("custom cellEdited handler can be added", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      events = list(
        cellEdited = js("function(cell) { return {action: 'customEdit'}; }")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true("cellEdited" %in% names(payload$events))
  })
})

test_that("rowDeleted event can be configured", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      events = list(
        rowDeleted = js("function(row) { return {action: 'deleted'}; }")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true("rowDeleted" %in% names(payload$events))
  })
})

test_that("rowAdded event can be configured", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      events = list(
        rowAdded = js("function(row) { return {action: 'added'}; }")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true("rowAdded" %in% names(payload$events))
  })
})

test_that("multiple event handlers can be configured together", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      events = list(
        cellEdited = js("function(cell) { return {action: 'edited'}; }"),
        rowDeleted = js("function(row) { return {action: 'deleted'}; }"),
        rowAdded = js("function(row) { return {action: 'added'}; }")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true("cellEdited" %in% names(payload$events))
    expect_true("rowDeleted" %in% names(payload$events))
    expect_true("rowAdded" %in% names(payload$events))
  })
})

test_that("editorParams pass through correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Age",
          "age",
          editor = "number",
          editorParams = list(min = 0, max = 120)
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$columns[[1]]$editorParams$min, 0)
    expect_equal(payload$options$columns[[1]]$editorParams$max, 120)
  })
})
