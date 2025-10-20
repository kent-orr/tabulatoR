# =============================================================================
# SHARED TEST UTILITIES FOR SHINY TESTS
# =============================================================================

library(shiny)
library(tabulatoR)

# Sample Data Fixtures --------------------------------------------------------

#' Create a simple test data frame
#'
#' @return A data.frame with mixed column types
sample_data <- function() {
  data.frame(
    id = 1:5,
    name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    age = c(25, 30, 35, 28, 42),
    active = c(TRUE, FALSE, TRUE, TRUE, FALSE),
    stringsAsFactors = FALSE
  )
}

#' Create an empty test data frame
#'
#' @return An empty data.frame with defined columns
empty_data <- function() {
  data.frame(
    id = integer(),
    name = character(),
    age = numeric(),
    stringsAsFactors = FALSE
  )
}

#' Create a single-row test data frame
#'
#' @return A data.frame with one row
single_row_data <- function() {
  data.frame(
    id = 1,
    name = "Alice",
    age = 25,
    stringsAsFactors = FALSE
  )
}

#' Create test data with various types
#'
#' @return A data.frame with multiple column types
mixed_type_data <- function() {
  data.frame(
    int_col = 1L,
    num_col = 1.5,
    char_col = "text",
    bool_col = TRUE,
    date_col = as.Date("2024-01-01"),
    stringsAsFactors = FALSE
  )
}

# Test App Helpers ------------------------------------------------------------

#' Create a minimal Shiny app for testing tabulatoR
#'
#' @param data_reactive A reactive expression returning a data.frame
#' @param render_args Additional arguments passed to renderTabulatoR
#' @param output_args Additional arguments passed to tabulatoROutput
#' @return A Shiny app object
create_test_app <- function(data_reactive = NULL, render_args = list(), output_args = list()) {
  ui <- fluidPage(
    do.call(tabulatoROutput, c(list(id = "test_table"), output_args))
  )

  server <- function(input, output, session) {
    if (is.null(data_reactive)) {
      data_reactive <- reactive(sample_data())
    }

    output$test_table <- do.call(
      renderTabulatoR,
      c(list(expr = data_reactive()), render_args)
    )
  }

  shinyApp(ui, server)
}

#' Create an editable Shiny app for testing
#'
#' @return A Shiny app with editable table and reactive data
create_editable_app <- function() {
  ui <- fluidPage(
    actionButton("add_row", "Add Row"),
    tabulatoROutput("test_table"),
    verbatimTextOutput("debug")
  )

  server <- function(input, output, session) {
    data <- reactiveVal(sample_data())

    output$test_table <- renderTabulatoR(
      data(),
      columns = c(
        Column("ID", "id", editable = FALSE),
        Column("Name", "name", editor = "input"),
        Column("Age", "age", editor = "number")
      )
    )

    observeEvent(input$test_table, {
      event <- input$test_table

      if (event$action == "cellEdited") {
        df <- data()
        row_idx <- which(df$id == event$row$id)
        df[row_idx, event$field] <- event$value
        data(df)
      }
    })

    output$debug <- renderPrint({
      list(
        data = data(),
        last_event = input$test_table
      )
    })
  }

  shinyApp(ui, server)
}

# JSON Verification Helpers ---------------------------------------------------

#' Parse JSON payload from renderTabulatoR
#'
#' @param json_string JSON string from renderer
#' @return Parsed list
parse_payload <- function(json_string) {
  jsonlite::fromJSON(json_string, simplifyVector = FALSE)
}

#' Verify JSON has expected structure
#'
#' @param json_string JSON string to verify
#' @param expected_fields Character vector of expected field names
expect_json_structure <- function(json_string, expected_fields = c("options", "events")) {
  payload <- parse_payload(json_string)

  for (field in expected_fields) {
    testthat::expect_true(
      field %in% names(payload),
      info = sprintf("Expected field '%s' in JSON payload", field)
    )
  }

  invisible(payload)
}

#' Verify data is present in JSON payload
#'
#' @param json_string JSON string to verify
#' @param expected_rows Expected number of data rows
expect_json_data <- function(json_string, expected_rows = NULL) {
  payload <- parse_payload(json_string)

  testthat::expect_true(
    "data" %in% names(payload$options),
    info = "Expected 'data' in options"
  )

  if (!is.null(expected_rows)) {
    actual_rows <- length(payload$options$data)
    testthat::expect_equal(
      actual_rows,
      expected_rows,
      info = sprintf("Expected %d rows, got %d", expected_rows, actual_rows)
    )
  }

  invisible(payload)
}

# Event Verification Helpers --------------------------------------------------

#' Verify event payload structure
#'
#' @param event Event object from input$tableId
#' @param expected_action Expected action name
expect_event_structure <- function(event, expected_action) {
  testthat::expect_true(
    !is.null(event),
    info = "Event should not be NULL"
  )

  testthat::expect_true(
    "action" %in% names(event),
    info = "Event should have 'action' field"
  )

  testthat::expect_equal(
    event$action,
    expected_action,
    info = sprintf("Expected action '%s'", expected_action)
  )

  invisible(event)
}

#' Verify cellEdited event structure
#'
#' @param event Event object from input$tableId
expect_cell_edited_event <- function(event) {
  expect_event_structure(event, "cellEdited")

  required_fields <- c("action", "field", "value", "row", "old_value")
  for (field in required_fields) {
    testthat::expect_true(
      field %in% names(event),
      info = sprintf("cellEdited event should have '%s' field", field)
    )
  }

  invisible(event)
}

#' Verify rowDeleted event structure
#'
#' @param event Event object from input$tableId
expect_row_deleted_event <- function(event) {
  expect_event_structure(event, "rowDeleted")

  testthat::expect_true(
    "row" %in% names(event),
    info = "rowDeleted event should have 'row' field"
  )

  invisible(event)
}
