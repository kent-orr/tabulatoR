library(tabulatoR)
library(shiny)
library(testthat)

# =============================================================================
# SHINY TABLE RENDERING TESTS
# =============================================================================
# These tests verify that renderTabulatoR works correctly within a Shiny
# reactive context using MockShinySession.

test_that("renderTabulatoR works in Shiny reactive context", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv())
    json <- isolate(renderer())

    # Verify JSON structure
    expect_type(json, "character")
    expect_json_structure(json)
    expect_json_data(json, expected_rows = 5)
  })
})

test_that("reactive data updates trigger table re-render", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactiveVal(sample_data())
    renderer <- renderTabulatoR(data_rv())

    # Get initial output
    initial_json <- isolate(renderer())
    initial_payload <- parse_payload(initial_json)
    expect_equal(length(initial_payload$options$data), 5)

    # Update reactive data
    data_rv(single_row_data())

    # Verify output updated
    updated_json <- isolate(renderer())
    updated_payload <- parse_payload(updated_json)
    expect_equal(length(updated_payload$options$data), 1)
  })
})

test_that("empty reactive data renders valid table", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(empty_data())
    renderer <- renderTabulatoR(data_rv())
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Should have data array (even if empty)
    expect_true("data" %in% names(payload$options))

    # Should have columns defined
    expect_true("columns" %in% names(payload$options))
    expect_true(length(payload$options$columns) > 0)
  })
})

test_that("single row reactive data renders correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(single_row_data())
    renderer <- renderTabulatoR(data_rv())
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(length(payload$options$data), 1)

    # Verify data values
    row_data <- payload$options$data[[1]]
    expect_equal(row_data$name[[1]], "Alice")
    expect_equal(row_data$age[[1]], 25)
  })
})

test_that("data types preserved in Shiny reactive rendering", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(mixed_type_data())
    renderer <- renderTabulatoR(data_rv())
    json <- isolate(renderer())
    payload <- parse_payload(json)

    row_data <- payload$options$data[[1]]

    # Integer
    expect_equal(row_data$int_col[[1]], 1)

    # Numeric
    expect_equal(row_data$num_col[[1]], 1.5)

    # Character
    expect_equal(row_data$char_col[[1]], "text")

    # Logical
    expect_equal(row_data$bool_col[[1]], TRUE)
  })
})

test_that("autoColumns works with reactive data", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), autoColumns = TRUE)
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Should have auto-generated columns
    expect_true("columns" %in% names(payload$options))
    columns <- payload$options$columns

    # Should have a column for each data field
    column_fields <- sapply(columns, function(col) col$field)
    expect_true("id" %in% column_fields)
    expect_true("name" %in% column_fields)
    expect_true("age" %in% column_fields)
    expect_true("active" %in% column_fields)
  })
})

test_that("custom columns work in reactive context", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    cols <- c(
      Column("ID", "id", width = "60px"),
      Column("Name", "name", editor = "input"),
      Column("Age", "age", editor = "number")
    )
    renderer <- renderTabulatoR(data_rv(), columns = cols)
    json <- isolate(renderer())
    payload <- parse_payload(json)

    columns <- payload$options$columns

    # Verify column properties
    expect_equal(columns[[1]]$title, "ID")
    expect_equal(columns[[1]]$field, "id")
    expect_equal(columns[[1]]$width, "60px")

    expect_equal(columns[[2]]$title, "Name")
    expect_equal(columns[[2]]$editor, "input")

    expect_equal(columns[[3]]$title, "Age")
    expect_equal(columns[[3]]$editor, "number")
  })
})

test_that("layout option passed through in Shiny context", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), layout = "fitData")
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$layout, "fitData")
  })
})

test_that("additional options passed via ... work in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      pagination = TRUE,
      paginationSize = 10,
      height = "300px"
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$pagination, TRUE)
    expect_equal(payload$options$paginationSize, 10)
    expect_equal(payload$options$height, "300px")
  })
})

test_that("events configuration passes through in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      events = list(
        cellClick = js("function(e, cell) { return {action: 'click'}; }")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true("events" %in% names(payload))
    expect_true("cellClick" %in% names(payload$events))
  })
})

test_that("renderTabulatoR errors on non-data.frame input", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    bad_data <- reactive(list(a = 1, b = 2))
    renderer <- renderTabulatoR(bad_data())

    expect_error(isolate(renderer()), "data.frame")
  })
})

test_that("editable parameter works in Shiny context", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), editable = TRUE)
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # With editable=TRUE and autoColumns, columns should have editor=TRUE
    columns <- payload$options$columns
    expect_true(all(sapply(columns, function(col) !is.null(col$editor))))
  })
})

test_that("editable = FALSE prevents auto-editor assignment", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), editable = FALSE)
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # With editable=FALSE, columns should not have editor
    columns <- payload$options$columns
    expect_true(all(sapply(columns, function(col) is.null(col$editor))))
  })
})
