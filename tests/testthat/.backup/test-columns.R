library(tabulatoR)

# Tests for Column

test_that("Column returns expected list", {
  expected <- list(list(title = "Name", field = "name", visible = TRUE, editable = FALSE))
  expect_equal(Column("Name", "name"), expected)
})

# Tests for ActionColumn

test_that("ActionColumn returns expected list", {
  expect_snapshot(ActionColumn("Edit", "edit"))
})

test_that("ActionColumn supports icons", {
  expect_snapshot(ActionColumn("Edit", "edit", icon = shiny::icon("edit")))
})
