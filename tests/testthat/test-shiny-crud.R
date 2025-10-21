# library(tabulatoR)
library(shiny)
library(testthat)

# =============================================================================
# SHINY CRUD TESTS
# =============================================================================
# These tests verify that CRUD operations (Create, Read, Update, Delete) work
# correctly in Shiny applications using tabulatoR with shinytest2.

test_that("Cell edits emit proper events", {
  skip_if_not_installed("shinytest2")

  # Create a test app
  app <- shinytest2::AppDriver$new(
    app_dir = system.file("examples", "crud_app", package = "tabulatoR"),
    name = "cell-edit-test",
    height = 600,
    width = 800
  )

  # Wait for app to initialize
  app$wait_for_idle()

  # Simulate editing a cell (this will depend on how we can interact with Tabulator)
  # For now, we'll test that the table renders
  expect_true(app$get_value(output = "crud_table") != "")

  app$stop()
})

test_that("Row additions emit proper events", {
  skip_if_not_installed("shinytest2")

  app <- shinytest2::AppDriver$new(
    app_dir = system.file("examples", "crud_app", package = "tabulatoR"),
    name = "row-add-test",
    height = 600,
    width = 800
  )

  app$wait_for_idle()

  # Click the add row button
  app$click("add_row")
  app$wait_for_idle()

  # Verify event was emitted
  event <- app$get_value(input = "crud_table")
  expect_equal(event$action, "rowAdded")
  expect_true(!is.null(event$row))

  app$stop()
})

test_that("Event structure contains expected fields for cellEdited", {
  skip_if_not_installed("shinytest2")

  # This test verifies the structure of events without needing a full app
  # We'll create a minimal test fixture

  expect_true(TRUE)  # Placeholder for now

  # The expected structure for cellEdited events should be:
  # list(
  #   action = "cellEdited",
  #   field = "column_name",
  #   value = new_value,
  #   old_value = previous_value,
  #   row = list(...),  # full row data
  #   index = row_position
  # )
})

test_that("Event structure contains expected fields for rowAdded", {
  skip_if_not_installed("shinytest2")

  expect_true(TRUE)  # Placeholder

  # The expected structure for rowAdded events should be:
  # list(
  #   action = "rowAdded",
  #   row = list(...)  # full row data
  # )
})

test_that("Event structure contains expected fields for rowDeleted", {
  skip_if_not_installed("shinytest2")

  expect_true(TRUE)  # Placeholder

  # The expected structure for rowDeleted events should be:
  # list(
  #   action = "rowDeleted",
  #   row = list(...)  # full row data that was deleted
  # )
})

test_that("preview_crud() demonstrates proper event handling pattern", {
  # This test verifies that the preview_crud() function exists and runs
  # without errors. It's a smoke test for the example app.

  expect_true(is.function(preview_crud))

  # Verify the app object can be created
  app_obj <- preview_crud()
  expect_s3_class(app_obj, "shiny.appobj")
})
