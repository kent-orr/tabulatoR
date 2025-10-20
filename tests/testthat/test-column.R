library(tabulatoR)
library(shiny)

# =============================================================================
# COLUMN FUNCTION TESTS
# =============================================================================
# These tests verify that the Column() function correctly constructs column
# definitions with various parameters and handles the editing logic properly.

# =============================================================================
# BASIC STRUCTURE TESTS
# =============================================================================

test_that("Column returns a list structure", {
  col <- Column("Name", "name")

  # Should return a list containing a list
  expect_type(col, "list")
  expect_length(col, 1)
  expect_type(col[[1]], "list")
})

test_that("Column includes required title and field", {
  col <- Column("User Name", "username")

  expect_equal(col[[1]]$title, "User Name")
  expect_equal(col[[1]]$field, "username")
})

test_that("Column sets visible = TRUE by default", {
  col <- Column("Name", "name")

  expect_true(col[[1]]$visible)
})

test_that("Column sets editable = FALSE by default", {
  col <- Column("Name", "name")

  expect_false(col[[1]]$editable)
})

test_that("Column minimal definition has expected structure", {
  col <- Column("ID", "id")
  expected <- list(list(
    title = "ID",
    field = "id",
    visible = TRUE,
    editable = FALSE
  ))

  expect_equal(col, expected)
})

# =============================================================================
# VISIBILITY AND LAYOUT TESTS
# =============================================================================

test_that("Column respects visible = FALSE", {
  col <- Column("Hidden", "hidden", visible = FALSE)

  expect_false(col[[1]]$visible)
})

test_that("Column accepts width parameter", {
  col <- Column("ID", "id", width = "80px")

  expect_equal(col[[1]]$width, "80px")
})

test_that("Column accepts width as percentage", {
  col <- Column("Name", "name", width = "25%")

  expect_equal(col[[1]]$width, "25%")
})

test_that("Column accepts hozAlign parameter", {
  col <- Column("Price", "price", hozAlign = "right")

  expect_equal(col[[1]]$hozAlign, "right")
})

test_that("Column accepts resizable parameter", {
  col <- Column("Name", "name", resizable = TRUE)

  expect_true(col[[1]]$resizable)
})

test_that("Column accepts resizable = FALSE", {
  col <- Column("Name", "name", resizable = FALSE)

  expect_false(col[[1]]$resizable)
})

# =============================================================================
# EDITING BEHAVIOR TESTS
# =============================================================================

test_that("Column with editable = TRUE sets editor = TRUE by default", {
  col <- Column("Name", "name", editable = TRUE)

  expect_true(col[[1]]$editable)
  expect_true(col[[1]]$editor)
})

test_that("Column with editor parameter sets editable = TRUE implicitly", {
  col <- Column("Name", "name", editor = "input")

  expect_true(col[[1]]$editable)
  expect_equal(col[[1]]$editor, "input")
})

test_that("Column with editor = 'input' works correctly", {
  col <- Column("Name", "name", editor = "input")

  expect_equal(col[[1]]$editor, "input")
  expect_true(col[[1]]$editable)
})

test_that("Column with editor = 'number' works correctly", {
  col <- Column("Age", "age", editor = "number")

  expect_equal(col[[1]]$editor, "number")
  expect_true(col[[1]]$editable)
})

test_that("Column with editor = 'textarea' works correctly", {
  col <- Column("Notes", "notes", editor = "textarea")

  expect_equal(col[[1]]$editor, "textarea")
  expect_true(col[[1]]$editable)
})

test_that("Column with editor = 'select' works correctly", {
  col <- Column("Status", "status", editor = "select")

  expect_equal(col[[1]]$editor, "select")
  expect_true(col[[1]]$editable)
})

test_that("Column with editable = FALSE does not set editor", {
  col <- Column("ID", "id", editable = FALSE)

  expect_false(col[[1]]$editable)
  expect_null(col[[1]]$editor)
})

test_that("Column with explicit editable = FALSE and editor respects editable", {
  # When editable is explicitly set to FALSE, it stays FALSE even with editor
  col <- Column("Name", "name", editable = FALSE, editor = "input")

  # Explicit editable = FALSE is preserved
  expect_false(col[[1]]$editable)
  expect_equal(col[[1]]$editor, "input")
})

test_that("Column with editorParams includes them", {
  params <- list(values = c("active", "inactive", "pending"))
  col <- Column("Status", "status", editor = "select", editorParams = params)

  expect_equal(col[[1]]$editorParams, params)
})

test_that("Column with editorParams for number editor", {
  params <- list(min = 0, max = 100, step = 5)
  col <- Column("Score", "score", editor = "number", editorParams = params)

  expect_equal(col[[1]]$editorParams, params)
})

# =============================================================================
# FORMATTER TESTS
# =============================================================================

test_that("Column accepts formatter as string", {
  col <- Column("Active", "active", formatter = "tickCross")

  expect_equal(col[[1]]$formatter, "tickCross")
})

test_that("Column accepts formatter as js() function", {
  formatter_fn <- js("function(cell) { return '$' + cell.getValue(); }")
  col <- Column("Price", "price", formatter = formatter_fn)

  expect_equal(col[[1]]$formatter, formatter_fn)
  expect_s3_class(col[[1]]$formatter, "tabulatoR_js")
})

test_that("Column accepts formatterParams", {
  params <- list(precision = 2)
  col <- Column("Price", "price", formatter = "money", formatterParams = params)

  expect_equal(col[[1]]$formatterParams, params)
})

test_that("Column with formatter and formatterParams", {
  params <- list(target = "_blank")
  col <- Column("URL", "url", formatter = "link", formatterParams = params)

  expect_equal(col[[1]]$formatter, "link")
  expect_equal(col[[1]]$formatterParams, params)
})

# =============================================================================
# CALLBACK TESTS
# =============================================================================

test_that("Column accepts cellClick callback", {
  callback <- js("function(e, cell) { console.log('clicked'); }")
  col <- Column("Name", "name", cellClick = callback)

  expect_equal(col[[1]]$cellClick, callback)
  expect_s3_class(col[[1]]$cellClick, "tabulatoR_js")
})

test_that("Column accepts cellEdited callback", {
  callback <- js("function(cell) { console.log('edited'); }")
  col <- Column("Name", "name", cellEdited = callback)

  expect_equal(col[[1]]$cellEdited, callback)
  expect_s3_class(col[[1]]$cellEdited, "tabulatoR_js")
})

test_that("Column with both cellClick and cellEdited", {
  click_cb <- js("function(e, cell) { console.log('click'); }")
  edited_cb <- js("function(cell) { console.log('edit'); }")
  col <- Column(
    "Name", "name",
    editor = "input",
    cellClick = click_cb,
    cellEdited = edited_cb
  )

  expect_equal(col[[1]]$cellClick, click_cb)
  expect_equal(col[[1]]$cellEdited, edited_cb)
})

# =============================================================================
# DOTS (...) PARAMETER TESTS
# =============================================================================

test_that("Column accepts additional parameters via ...", {
  col <- Column(
    "Name", "name",
    sorter = "string",
    headerSort = TRUE
  )

  expect_equal(col[[1]]$sorter, "string")
  expect_true(col[[1]]$headerSort)
})

test_that("Column ... parameters are added to config", {
  col <- Column(
    "Price", "price",
    tooltip = "Item price",
    minWidth = "100",
    maxWidth = "200"
  )

  expect_equal(col[[1]]$tooltip, "Item price")
  expect_equal(col[[1]]$minWidth, "100")
  expect_equal(col[[1]]$maxWidth, "200")
})

test_that("Column with custom Tabulator options via ...", {
  col <- Column(
    "Name", "name",
    frozen = TRUE,
    headerVertical = TRUE,
    clipboard = TRUE
  )

  expect_true(col[[1]]$frozen)
  expect_true(col[[1]]$headerVertical)
  expect_true(col[[1]]$clipboard)
})

# =============================================================================
# .opts PARAMETER TESTS
# =============================================================================

test_that("Column accepts .opts parameter", {
  opts <- list(
    hozAlign = "center",
    width = "100px",
    sorter = "number"
  )
  col <- Column("ID", "id", .opts = opts)

  expect_equal(col[[1]]$hozAlign, "center")
  expect_equal(col[[1]]$width, "100px")
  expect_equal(col[[1]]$sorter, "number")
})

test_that("Column .opts takes precedence over explicit parameters", {
  opts <- list(width = "100px", hozAlign = "left")
  col <- Column("Name", "name", width = "150px", .opts = opts)

  # .opts width takes precedence over explicit parameter
  expect_equal(col[[1]]$width, "100px")
  # hozAlign from .opts should be present
  expect_equal(col[[1]]$hozAlign, "left")
})

test_that("Column .opts takes precedence over explicit editable", {
  opts <- list(editable = TRUE, visible = FALSE)
  col <- Column("Name", "name", editable = FALSE, .opts = opts)

  # .opts editable takes precedence over explicit parameter
  expect_true(col[[1]]$editable)
  # visible from .opts should be present
  expect_false(col[[1]]$visible)
})

test_that("Column .opts with ... parameters merge correctly", {
  opts <- list(
    sorter = "string",
    headerSort = TRUE
  )
  col <- Column(
    "Name", "name",
    width = "200px",
    hozAlign = "center",
    .opts = opts
  )

  # Should have all parameters
  expect_equal(col[[1]]$sorter, "string")
  expect_true(col[[1]]$headerSort)
  expect_equal(col[[1]]$width, "200px")
  expect_equal(col[[1]]$hozAlign, "center")
})

# =============================================================================
# COMPLEX CONFIGURATION TESTS
# =============================================================================

test_that("Column with full editing configuration", {
  col <- Column(
    title = "Status",
    field = "status",
    editor = "select",
    editorParams = list(values = c("active", "inactive")),
    cellEdited = js("function(cell) { console.log('edited'); }")
  )

  expect_equal(col[[1]]$title, "Status")
  expect_equal(col[[1]]$field, "status")
  expect_true(col[[1]]$editable)
  expect_equal(col[[1]]$editor, "select")
  expect_equal(col[[1]]$editorParams$values, c("active", "inactive"))
  expect_s3_class(col[[1]]$cellEdited, "tabulatoR_js")
})

test_that("Column with full formatting configuration", {
  col <- Column(
    title = "Price",
    field = "price",
    formatter = js("function(cell) { return '$' + cell.getValue(); }"),
    formatterParams = list(precision = 2),
    hozAlign = "right",
    width = "120px"
  )

  expect_s3_class(col[[1]]$formatter, "tabulatoR_js")
  expect_equal(col[[1]]$formatterParams$precision, 2)
  expect_equal(col[[1]]$hozAlign, "right")
  expect_equal(col[[1]]$width, "120px")
})

test_that("Column with mixed standard and custom options", {
  col <- Column(
    "Name", "name",
    width = "200px",
    editor = "input",
    sorter = "string",
    headerSort = TRUE,
    frozen = TRUE,
    tooltip = "User name"
  )

  # Standard options
  expect_equal(col[[1]]$width, "200px")
  expect_equal(col[[1]]$editor, "input")
  expect_true(col[[1]]$editable)

  # Custom options via ...
  expect_equal(col[[1]]$sorter, "string")
  expect_true(col[[1]]$headerSort)
  expect_true(col[[1]]$frozen)
  expect_equal(col[[1]]$tooltip, "User name")
})

# =============================================================================
# COLUMN COMBINATION TESTS
# =============================================================================

test_that("Multiple columns can be combined with c()", {
  cols <- c(
    Column("ID", "id", width = "60px"),
    Column("Name", "name", editor = "input"),
    Column("Age", "age", hozAlign = "right")
  )

  expect_length(cols, 3)
  expect_equal(cols[[1]]$field, "id")
  expect_equal(cols[[2]]$field, "name")
  expect_equal(cols[[3]]$field, "age")
})

test_that("Column list preserves all configurations when combined", {
  cols <- c(
    Column("ID", "id", editable = FALSE),
    Column("Name", "name", editable = TRUE),
    Column("Status", "status", editor = "select")
  )

  # First column
  expect_false(cols[[1]]$editable)
  expect_null(cols[[1]]$editor)

  # Second column
  expect_true(cols[[2]]$editable)
  expect_true(cols[[2]]$editor)

  # Third column
  expect_true(cols[[3]]$editable)
  expect_equal(cols[[3]]$editor, "select")
})

# =============================================================================
# NULL PARAMETER FILTERING TESTS
# =============================================================================

test_that("Column does not include NULL parameters in output", {
  col <- Column("Name", "name")

  # NULL parameters should be filtered out
  expect_null(col[[1]]$hozAlign)
  expect_null(col[[1]]$width)
  expect_null(col[[1]]$resizable)
  expect_null(col[[1]]$editor)
  expect_null(col[[1]]$formatter)

  # But these are not NULL in the list (they're not keys)
  expect_false("hozAlign" %in% names(col[[1]]))
  expect_false("width" %in% names(col[[1]]))
})

test_that("Column only includes explicitly set parameters", {
  col <- Column("Name", "name", width = "100px")

  # Should include set parameters
  expect_true("width" %in% names(col[[1]]))
  expect_equal(col[[1]]$width, "100px")

  # Should not include unset parameters
  expect_false("hozAlign" %in% names(col[[1]]))
  expect_false("resizable" %in% names(col[[1]]))
})

# =============================================================================
# EDGE CASES AND ERROR HANDLING
# =============================================================================

test_that("Column with empty string title", {
  col <- Column("", "field")

  expect_equal(col[[1]]$title, "")
  expect_equal(col[[1]]$field, "field")
})

test_that("Column with special characters in title", {
  col <- Column("Name (Last, First)", "name")

  expect_equal(col[[1]]$title, "Name (Last, First)")
})

test_that("Column with unicode characters in title", {
  col <- Column("Nombre \u00e9\u00f1", "name")

  expect_equal(col[[1]]$title, "Nombre \u00e9\u00f1")
})

test_that("Column with numeric width without units", {
  col <- Column("ID", "id", width = 100)

  expect_equal(col[[1]]$width, 100)
})

test_that("Column editor = TRUE is preserved", {
  col <- Column("Name", "name", editable = TRUE)

  # When editable = TRUE and editor is not provided, editor should be TRUE
  expect_true(col[[1]]$editor)
})

test_that("Column editor = FALSE is preserved when explicitly set", {
  # This is an edge case - explicitly setting editor = FALSE
  col <- Column("Name", "name", editor = FALSE)

  # editor = FALSE should implicitly set editable = TRUE (any editor value does)
  expect_true(col[[1]]$editable)
  expect_false(col[[1]]$editor)
})

# =============================================================================
# DOCUMENTATION COMPLIANCE TESTS
# =============================================================================

test_that("Column editable logic matches documentation", {
  # From docs: "Supplying editor implicitly enables editing"
  col1 <- Column("Name", "name", editor = "input")
  expect_true(col1[[1]]$editable)

  # From docs: "If editable = TRUE and no editor is provided,
  # Tabulator attempts to guess the editor (editor = TRUE)"
  col2 <- Column("Name", "name", editable = TRUE)
  expect_true(col2[[1]]$editor)
})

test_that("Column parameter precedence: .opts wins", {
  # Despite documentation saying "Values in ... will override matching keys in .opts"
  # the actual implementation has .opts take precedence
  # This is because c(.opts, args, ...) puts .opts first, and $ returns first match
  opts <- list(sorter = "string")
  col <- Column("Name", "name", sorter = "number", .opts = opts)

  # .opts takes precedence (first in list)
  expect_equal(col[[1]]$sorter, "string")
})

test_that("Column returns structure suitable for renderTabulatoR", {
  col <- Column("Name", "name", editor = "input")

  # Should be a list containing a list with column config
  expect_type(col, "list")
  expect_type(col[[1]], "list")
  expect_true(all(c("title", "field", "visible", "editable") %in% names(col[[1]])))
})
