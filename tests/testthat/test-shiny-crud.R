# library(tabulatoR)
library(shiny)
library(testthat)

# =============================================================================
# SHINY CRUD TESTS
# =============================================================================
# These tests verify that CRUD operations (Create, Read, Update, Delete) work
# correctly in Shiny applications using tabulatoR with shinytest2.

test_that("CRUD app renders successfully", {
  skip_if_not_installed("shinytest2")
  skip_on_cran()

  # Create a test app
  app <- shinytest2::AppDriver$new(
    app_dir = "apps/crud_app",
    name = "crud-render-test",
    height = 600,
    width = 800
  )

  # Wait for app to initialize
  app$wait_for_idle()

  # Verify the table renders
  expect_true(!is.null(app$get_value(output = "crud_table")))

  # Verify the inputs display exists
  expect_true(!is.null(app$get_value(output = "crud_inputs")))

  app$stop()
})

test_that("Add row button triggers rowAdded event", {
  skip_if_not_installed("shinytest2")
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = "apps/crud_app",
    name = "row-add-test",
    height = 600,
    width = 800
  )

  app$wait_for_idle()

  # Click the add row button
  app$click("add_row")
  app$wait_for_idle(500)

  # Verify event was emitted
  event <- app$get_value(input = "crud_table")
  expect_equal(event$action, "rowAdded")
  expect_true(!is.null(event$row))

  app$stop()
})

test_that("Event structure contains expected fields for cellEdited", {
  skip_if_not_installed("shinytest2")
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = "apps/crud_app",
    name = "cell-edit-test",
    height = 600,
    width = 800
  )

  app$wait_for_idle()

  # Simulate editing a cell by clicking it and programmatically setting the editor value
  # We'll edit the first row's 'mpg' column
  app$run_js("
    var table = Tabulator.findTable('#crud_table')[0];
    var row = table.getRowFromPosition(1);
    var cell = row.getCell('mpg');

    // Get the old value before editing
    var oldValue = cell.getValue();

    // Trigger edit on the cell
    cell.edit();

    // Wait a bit for the editor to initialize, then set value and trigger blur
    setTimeout(function() {
      var input = cell.getElement().querySelector('input');
      if (input) {
        input.value = '999';
        input.dispatchEvent(new Event('change', { bubbles: true }));
        input.blur();
      }
    }, 100);
  ")

  app$wait_for_idle(1000)

  # Verify the event structure
  event <- app$get_value(input = "crud_table")

  expect_equal(event$action, "cellEdited")
  expect_true("field" %in% names(event))
  expect_true("value" %in% names(event))
  expect_true("old_value" %in% names(event))
  expect_true("row" %in% names(event))
  expect_true("index" %in% names(event))

  # Verify the specific values for this edit
  expect_equal(event$field, "mpg")
  expect_equal(as.numeric(event$value), 999)

  app$stop()
})

test_that("Event structure contains expected fields for rowAdded", {
  skip_if_not_installed("shinytest2")
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = "apps/crud_app",
    name = "row-added-structure-test",
    height = 600,
    width = 800
  )

  app$wait_for_idle()

  # Click the add row button to trigger rowAdded event
  app$click("add_row")
  app$wait_for_idle(500)

  # Verify the event structure
  event <- app$get_value(input = "crud_table")

  expect_equal(event$action, "rowAdded")
  expect_true("row" %in% names(event))
  expect_true(is.list(event$row))

  # The row should contain data (even if NA values)
  expect_true(length(event$row) > 0)

  app$stop()
})

test_that("Event structure contains expected fields for rowDeleted", {
  skip_if_not_installed("shinytest2")
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = "apps/crud_app",
    name = "row-deleted-test",
    height = 600,
    width = 800
  )

  app$wait_for_idle()

  # Delete a row directly via JavaScript to trigger rowDeleted event
  # Using row.delete() which should properly trigger the event
  app$run_js("
    var table = Tabulator.findTable('#crud_table')[0];
    var row = table.getRowFromPosition(1);
    row.delete();
  ")

  app$wait_for_idle(500)

  # Verify the event structure
  event <- app$get_value(input = "crud_table")

  expect_equal(event$action, "rowDeleted")
  expect_true("row" %in% names(event))
  expect_true(is.list(event$row))

  # The row should contain the data that was deleted (first row of mtcars)
  expect_true(length(event$row) > 0)
  expect_true("mpg" %in% names(event$row))

  app$stop()
})

test_that("preview_crud() demonstrates proper event handling pattern", {
  # This test verifies that the preview_crud() function exists and runs
  # without errors. It's a smoke test for the example app.

  expect_true(is.function(preview_crud))

  # Verify the app object can be created
  app_obj <- preview_crud()
  expect_s3_class(app_obj, "shiny.appobj")
})
