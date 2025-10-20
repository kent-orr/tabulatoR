library(tabulatoR)
library(shiny)

# Helper function for readable JSON snapshots
expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

# =============================================================================
# BASIC TABLE RENDERING
# =============================================================================

test_that("renderTabulatoR works with simple numeric data", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1:3))
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())

    # Should return valid JSON string
    expect_type(json, "character")

    # Should parse without error
    payload <- jsonlite::fromJSON(json)

    # Should have expected structure
    expect_true("options" %in% names(payload))
    expect_true("data" %in% names(payload$options))
    expect_true("columns" %in% names(payload$options))
  })
})

test_that("renderTabulatoR works with mixed data types", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      num = c(1.5, 2.5, 3.5),
      char = c("a", "b", "c"),
      lgl = c(TRUE, FALSE, TRUE),
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should have 4 columns
    expect_equal(length(payload$options$columns), 4)

    # Column names should match data.frame
    col_fields <- sapply(payload$options$columns, `[[`, "field")
    expect_equal(col_fields, c("num", "char", "lgl"))
  })
})

test_that("renderTabulatoR handles empty data.frame", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame())
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should have empty data array
    expect_equal(length(payload$options$data), 0)
  })
})

test_that("renderTabulatoR handles single row", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(a = 1, b = "x"))
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should have 1 data row
    expect_equal(nrow(payload$options$data), 1)
    expect_equal(payload$options$data$a, 1)
    expect_equal(payload$options$data$b, "x")
  })
})

test_that("renderTabulatoR requires data.frame input", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal("not a data frame")
    renderer <- renderTabulatoR(rv())

    # Should error when trying to render
    expect_error(isolate(renderer()), "data.frame")
  })
})

# =============================================================================
# AUTO-GENERATED COLUMNS
# =============================================================================

test_that("autoColumns generates columns from data when enabled", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:2, y = 3:4)
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv(), autoColumns = TRUE)
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should have auto-generated columns
    expect_equal(length(payload$options$columns), 2)
    expect_equal(payload$options$columns[[1]]$field, "x")
    expect_equal(payload$options$columns[[1]]$title, "x")
    expect_equal(payload$options$columns[[2]]$field, "y")
    expect_equal(payload$options$columns[[2]]$title, "y")
  })
})

test_that("autoColumns respects editable flag", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:2)
    rv <- reactiveVal(df)

    # With editable = TRUE
    renderer_editable <- renderTabulatoR(rv(), autoColumns = TRUE, editable = TRUE)
    json_editable <- isolate(renderer_editable())
    payload_editable <- jsonlite::fromJSON(json_editable)

    expect_equal(payload_editable$options$columns[[1]]$editor, TRUE)

    # With editable = FALSE
    renderer_readonly <- renderTabulatoR(rv(), autoColumns = TRUE, editable = FALSE)
    json_readonly <- isolate(renderer_readonly())
    payload_readonly <- jsonlite::fromJSON(json_readonly)

    expect_null(payload_readonly$options$columns[[1]]$editor)
  })
})

test_that("custom columns override autoColumns", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:2, y = 3:4)
    rv <- reactiveVal(df)

    custom_col <- list(title = "Custom", field = "x", width = "100px")
    renderer <- renderTabulatoR(rv(), columns = c(custom_col), autoColumns = TRUE)
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should use custom columns, not auto-generated
    expect_equal(length(payload$options$columns), 1)
    expect_equal(payload$options$columns[[1]]$title, "Custom")
    expect_equal(payload$options$columns[[1]]$width, "100px")
  })
})

# =============================================================================
# LAYOUT OPTIONS
# =============================================================================

test_that("layout parameter is included in payload", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))

    renderer <- renderTabulatoR(rv(), layout = "fitData")
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_equal(payload$options$layout, "fitData")
  })
})

test_that("default layout is fitColumns", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_equal(payload$options$layout, "fitColumns")
  })
})

# =============================================================================
# ADDITIONAL OPTIONS (.opts and ...)
# =============================================================================

test_that("additional options via ... are included", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    renderer <- renderTabulatoR(rv(), pagination = TRUE, paginationSize = 10)
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_equal(payload$options$pagination, TRUE)
    expect_equal(payload$options$paginationSize, 10)
  })
})

test_that(".opts parameter includes options", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    opts <- list(selectable = 1, movableRows = TRUE)
    renderer <- renderTabulatoR(rv(), .opts = opts)
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_equal(payload$options$selectable, 1)
    expect_equal(payload$options$movableRows, TRUE)
  })
})

test_that("... overrides .opts for matching keys", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    opts <- list(layout = "fitData", height = "300px")
    renderer <- renderTabulatoR(rv(), .opts = opts, layout = "fitColumns")
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # layout from ... should win
    expect_equal(payload$options$layout, "fitColumns")
    # height from .opts should be included
    expect_equal(payload$options$height, "300px")
  })
})

# =============================================================================
# DATA SERIALIZATION
# =============================================================================

test_that("data is serialized as array of row objects", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1:2, b = c("x", "y"))
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Data should be array (data.frame in R after fromJSON)
    expect_true(is.data.frame(payload$options$data))
    expect_equal(nrow(payload$options$data), 2)
    expect_equal(payload$options$data$a, c(1, 2))
    expect_equal(payload$options$data$b, c("x", "y"))
  })
})

test_that("scalars are unboxed in JSON", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    renderer <- renderTabulatoR(rv(), layout = "fitColumns")
    json <- isolate(renderer())

    # Layout should be a string, not an array
    expect_match(json, '"layout"\\s*:\\s*"fitColumns"')
    expect_false(grepl('"layout"\\s*:\\s*\\["fitColumns"\\]', json))
  })
})

# =============================================================================
# PAYLOAD STRUCTURE
# =============================================================================

test_that("payload has correct top-level structure", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    # Should have options and events at top level
    expect_setequal(names(payload), c("options", "events"))
  })
})

test_that("options contains data and columns", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(x = 1))
    renderer <- renderTabulatoR(rv())
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_true("data" %in% names(payload$options))
    expect_true("columns" %in% names(payload$options))
    expect_true("layout" %in% names(payload$options))
  })
})

# =============================================================================
# COLUMN DEFINITIONS
# =============================================================================

test_that("Column() creates expected structure", {
  col <- Column(title = "Name", field = "name")

  # Should return a single-element list containing the column config
  expect_type(col, "list")
  expect_equal(length(col), 1)

  # The actual config should be in [[1]]
  config <- col[[1]]
  expect_equal(config$title, "Name")
  expect_equal(config$field, "name")
  expect_equal(config$visible, TRUE)
  expect_equal(config$editable, FALSE)
})

test_that("Column() handles optional parameters", {
  col <- Column(
    title = "Price",
    field = "price",
    hozAlign = "right",
    width = "100px",
    resizable = TRUE
  )

  config <- col[[1]]
  expect_equal(config$hozAlign, "right")
  expect_equal(config$width, "100px")
  expect_equal(config$resizable, TRUE)
})

test_that("Column() editor parameter enables editing", {
  col <- Column(title = "Name", field = "name", editor = "input")

  config <- col[[1]]
  expect_equal(config$editable, TRUE)
  expect_equal(config$editor, "input")
})

test_that("Column() editable=TRUE with no editor sets editor=TRUE", {
  col <- Column(title = "Name", field = "name", editable = TRUE)

  config <- col[[1]]
  expect_equal(config$editable, TRUE)
  expect_equal(config$editor, TRUE)
})

test_that("Column() explicit editable=FALSE prevents editing", {
  col <- Column(title = "Name", field = "name", editable = FALSE, editor = "input")

  config <- col[[1]]
  # editable should remain FALSE even with editor specified
  expect_equal(config$editable, FALSE)
  expect_equal(config$editor, "input")
})

test_that("Column() ... parameters are included", {
  col <- Column(
    title = "Custom",
    field = "field",
    sorter = "number",
    headerFilter = TRUE,
    customProp = "value"
  )

  config <- col[[1]]
  expect_equal(config$sorter, "number")
  expect_equal(config$headerFilter, TRUE)
  expect_equal(config$customProp, "value")
})

test_that("Column() .opts parameter works", {
  opts <- list(hozAlign = "center", width = "50px")
  col <- Column(title = "ID", field = "id", .opts = opts)

  config <- col[[1]]
  expect_equal(config$hozAlign, "center")
  expect_equal(config$width, "50px")
})

test_that("Column() ... overrides .opts", {
  opts <- list(width = "100px", hozAlign = "left")
  col <- Column(title = "ID", field = "id", .opts = opts, width = "200px")

  config <- col[[1]]
  expect_equal(config$width, "200px")
  expect_equal(config$hozAlign, "left")
})

test_that("ActionColumn() creates button formatter", {
  col <- ActionColumn(label = "Edit", action = "edit")

  config <- col[[1]]
  expect_equal(config$title, "Edit")
  expect_equal(config$field, "edit")

  # Should have a formatter (we'll test its content in JS tests)
  expect_true(!is.null(config$formatter))
})

test_that("ActionColumn() supports custom CSS class", {
  col <- ActionColumn(label = "Delete", action = "delete", class = "btn btn-danger")

  config <- col[[1]]
  formatter_str <- as.character(config$formatter)

  # Should include the custom class in the JavaScript
  expect_match(formatter_str, "btn btn-danger")
})

test_that("ActionColumn() includes icon HTML", {
  col <- ActionColumn(label = "Edit", action = "edit", icon = shiny::icon("edit"))

  config <- col[[1]]
  formatter_str <- as.character(config$formatter)

  # Should include icon markup
  expect_match(formatter_str, "fa-edit")
})

test_that("multiple columns work with c()", {
  cols <- c(
    Column("ID", "id"),
    Column("Name", "name"),
    Column("Email", "email")
  )

  # Should be a list of 3 column configs
  expect_equal(length(cols), 3)
  expect_equal(cols[[1]]$field, "id")
  expect_equal(cols[[2]]$field, "name")
  expect_equal(cols[[3]]$field, "email")
})

test_that("columns integrate with renderTabulatoR", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(id = 1:2, name = c("Alice", "Bob"))
    rv <- reactiveVal(df)

    cols <- c(
      Column("ID", "id", width = "50px"),
      Column("Name", "name", editor = "input")
    )

    renderer <- renderTabulatoR(rv(), columns = cols)
    json <- isolate(renderer())
    payload <- jsonlite::fromJSON(json)

    expect_equal(length(payload$options$columns), 2)
    expect_equal(payload$options$columns[[1]]$width, "50px")
    expect_equal(payload$options$columns[[2]]$editor, "input")
  })
})

# =============================================================================
# COLUMN FLATTENING
# =============================================================================

test_that("flatten_columns handles empty input", {
  expect_equal(flatten_columns(c()), list())
  expect_equal(flatten_columns(list()), list())
})

test_that("flatten_columns handles c() syntax", {
  cols <- c(Column("A", "a"), Column("B", "b"))
  result <- flatten_columns(cols)

  expect_equal(length(result), 2)
  expect_null(names(result))
  expect_equal(result[[1]]$field, "a")
  expect_equal(result[[2]]$field, "b")
})

test_that("flatten_columns handles list() syntax", {
  cols <- list(Column("A", "a"), Column("B", "b"))
  result <- flatten_columns(cols)

  expect_equal(length(result), 2)
  expect_null(names(result))
  expect_equal(result[[1]]$field, "a")
  expect_equal(result[[2]]$field, "b")
})

test_that("flatten_columns handles already flat lists", {
  cols <- list(
    list(title = "A", field = "a"),
    list(title = "B", field = "b")
  )
  result <- flatten_columns(cols)

  expect_equal(result, cols)
  expect_null(names(result))
})

test_that("flatten_columns preserves column properties", {
  cols <- c(
    Column("Name", "name", width = "200px", editor = "input"),
    Column("Age", "age", hozAlign = "right")
  )
  result <- flatten_columns(cols)

  expect_equal(result[[1]]$width, "200px")
  expect_equal(result[[1]]$editor, "input")
  expect_equal(result[[2]]$hozAlign, "right")
})

# =============================================================================
# SNAPSHOT TEST FOR FULL OUTPUT
# =============================================================================

test_that("complete basic table payload matches snapshot", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      id = 1:3,
      name = c("Alice", "Bob", "Charlie"),
      score = c(95, 87, 92)
    )
    rv <- reactiveVal(df)
    renderer <- renderTabulatoR(rv(), layout = "fitColumns", editable = TRUE)
    json <- isolate(renderer())

    expect_snapshot_json(json)
  })
})

test_that("table with custom columns matches snapshot", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(id = 1:2, name = c("Alice", "Bob"), score = c(95, 87))
    rv <- reactiveVal(df)

    cols <- c(
      Column("ID", "id", width = "50px", hozAlign = "center"),
      Column("Name", "name", editor = "input"),
      Column("Score", "score", hozAlign = "right", editor = "number")
    )

    renderer <- renderTabulatoR(rv(), columns = cols, layout = "fitData")
    json <- isolate(renderer())

    expect_snapshot_json(json)
  })
})
