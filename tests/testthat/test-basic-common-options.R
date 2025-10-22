library(tabulatoR)
library(shiny)

# Helper function for readable JSON snapshots
expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

# =============================================================================
# COMMON TABULATOR OPTIONS TESTS
# =============================================================================
# These tests verify that common Tabulator options passed through ... or .opts
# are properly serialized into the JSON payload. These options don't have
# explicit parameters in renderTabulatoR() but are frequently used:
#
# - Pagination (pagination, paginationSize, paginationMode, paginationCounter)
# - Sorting (initialSort, sortMode)
# - Filtering (filterMode, headerFilterPlaceholder)
# - Selection (selectable, selectableRangeMode)
# - Grouping (groupBy, groupStartOpen, groupHeader)
# - Height/sizing (height, maxHeight, minHeight)
# - Tooltips (tooltips, tooltipsHeader)
# - Row/cell styling (rowHeight)
# - Responsiveness (responsiveLayout, responsiveLayoutCollapseStartOpen)
# - Progressive rendering (progressiveLoad, progressiveLoadDelay)
# - Virtual DOM (renderVertical, renderHorizontal)

# =============================================================================
# PAGINATION OPTIONS
# =============================================================================

test_that("pagination options serialize correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:100)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      pagination = TRUE,
      paginationSize = 10,
      paginationMode = "local"
    )
    json <- isolate(renderer())

    expect_match(json, '"pagination"\\s*:\\s*true')
    expect_match(json, '"paginationSize"\\s*:\\s*10')
    expect_match(json, '"paginationMode"\\s*:\\s*"local"')
  })
})

test_that("pagination with paginationSizeSelector", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:100)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      pagination = TRUE,
      paginationSize = 10,
      paginationSizeSelector = c(10, 25, 50, 100)
    )
    json <- isolate(renderer())

    expect_match(json, '"paginationSizeSelector"')
    expect_match(json, '\\[\\s*10\\s*,\\s*25\\s*,\\s*50\\s*,\\s*100\\s*\\]')
  })
})

test_that("pagination counter can be customized", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:100)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      pagination = TRUE,
      paginationCounter = "rows"
    )
    json <- isolate(renderer())

    expect_match(json, '"paginationCounter"\\s*:\\s*"rows"')
  })
})

# =============================================================================
# SORTING OPTIONS
# =============================================================================

test_that("initialSort serializes correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = c("Bob", "Alice"), age = c(30, 25))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      initialSort = list(
        list(column = "name", dir = "asc")
      )
    )
    json <- isolate(renderer())

    expect_match(json, '"initialSort"')
    expect_match(json, '"column"\\s*:\\s*"name"')
    expect_match(json, '"dir"\\s*:\\s*"asc"')
  })
})

test_that("sortMode option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      sortMode = "remote"
    )
    json <- isolate(renderer())

    expect_match(json, '"sortMode"\\s*:\\s*"remote"')
  })
})

test_that("multiple column initial sort", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(dept = c("A", "A", "B"), age = c(25, 30, 35))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      initialSort = list(
        list(column = "dept", dir = "asc"),
        list(column = "age", dir = "desc")
      )
    )
    json <- isolate(renderer())

    expect_match(json, '"initialSort"')
    # Should have both sort definitions
    expect_match(json, '"column"\\s*:\\s*"dept"')
    expect_match(json, '"column"\\s*:\\s*"age"')
  })
})

# =============================================================================
# FILTERING OPTIONS
# =============================================================================

test_that("filterMode option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = c("Alice", "Bob"))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      filterMode = "remote"
    )
    json <- isolate(renderer())

    expect_match(json, '"filterMode"\\s*:\\s*"remote"')
  })
})

test_that("initialFilter option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(status = c("active", "inactive", "active"))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      initialFilter = list(
        list(field = "status", type = "=", value = "active")
      )
    )
    json <- isolate(renderer())

    expect_match(json, '"initialFilter"')
    expect_match(json, '"field"\\s*:\\s*"status"')
    expect_match(json, '"type"\\s*:\\s*"="')
    expect_match(json, '"value"\\s*:\\s*"active"')
  })
})

# =============================================================================
# SELECTION OPTIONS
# =============================================================================

test_that("selectable option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      selectable = TRUE
    )
    json <- isolate(renderer())

    expect_match(json, '"selectable"\\s*:\\s*true')
  })
})

test_that("selectable with numeric limit", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      selectable = 3
    )
    json <- isolate(renderer())

    expect_match(json, '"selectable"\\s*:\\s*3')
  })
})

test_that("selectableRangeMode option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      selectable = TRUE,
      selectableRangeMode = "click"
    )
    json <- isolate(renderer())

    expect_match(json, '"selectableRangeMode"\\s*:\\s*"click"')
  })
})

# =============================================================================
# GROUPING OPTIONS
# =============================================================================

test_that("groupBy option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(category = c("A", "A", "B"), value = 1:3)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      groupBy = "category"
    )
    json <- isolate(renderer())

    expect_match(json, '"groupBy"\\s*:\\s*"category"')
  })
})

test_that("groupBy with groupStartOpen option", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(category = c("A", "B"), value = 1:2)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      groupBy = "category",
      groupStartOpen = FALSE
    )
    json <- isolate(renderer())

    expect_match(json, '"groupBy"\\s*:\\s*"category"')
    expect_match(json, '"groupStartOpen"\\s*:\\s*false')
  })
})

test_that("groupHeader as JS function", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(category = c("A", "B"), value = 1:2)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      groupBy = "category",
      groupHeader = js("function(value, count) { return value + ' (' + count + ')'; }")
    )
    json <- isolate(renderer())

    expect_match(json, '"groupHeader"')
    expect_match(json, 'function\\(value, count\\)')
  })
})

# =============================================================================
# HEIGHT AND SIZING OPTIONS
# =============================================================================

test_that("height option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:100)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      height = "400px"
    )
    json <- isolate(renderer())

    expect_match(json, '"height"\\s*:\\s*"400px"')
  })
})

test_that("maxHeight option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:100)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      maxHeight = "600px"
    )
    json <- isolate(renderer())

    expect_match(json, '"maxHeight"\\s*:\\s*"600px"')
  })
})

test_that("minHeight option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      minHeight = "200px"
    )
    json <- isolate(renderer())

    expect_match(json, '"minHeight"\\s*:\\s*"200px"')
  })
})

test_that("numeric height values work", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:10)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      height = 400
    )
    json <- isolate(renderer())

    expect_match(json, '"height"\\s*:\\s*400')
  })
})

# =============================================================================
# TOOLTIP OPTIONS
# =============================================================================

test_that("tooltips option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      tooltips = TRUE
    )
    json <- isolate(renderer())

    expect_match(json, '"tooltips"\\s*:\\s*true')
  })
})

test_that("tooltips with JS function", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      tooltips = js("function(cell) { return 'Value: ' + cell.getValue(); }")
    )
    json <- isolate(renderer())

    expect_match(json, '"tooltips"')
    expect_match(json, 'function\\(cell\\)')
  })
})

test_that("tooltipsHeader option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      tooltipsHeader = TRUE
    )
    json <- isolate(renderer())

    expect_match(json, '"tooltipsHeader"\\s*:\\s*true')
  })
})

# =============================================================================
# ROW STYLING OPTIONS
# =============================================================================

test_that("rowHeight option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      rowHeight = 40
    )
    json <- isolate(renderer())

    expect_match(json, '"rowHeight"\\s*:\\s*40')
  })
})

test_that("rowFormatter as JS function", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(status = c("active", "inactive"))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      rowFormatter = js("function(row) { if(row.getData().status === 'active') row.getElement().style.backgroundColor = '#cfc'; }")
    )
    json <- isolate(renderer())

    expect_match(json, '"rowFormatter"')
    expect_match(json, 'function\\(row\\)')
  })
})

# =============================================================================
# RESPONSIVE LAYOUT OPTIONS
# =============================================================================

test_that("responsiveLayout option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = 2, c = 3, d = 4)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      responsiveLayout = "collapse"
    )
    json <- isolate(renderer())

    expect_match(json, '"responsiveLayout"\\s*:\\s*"collapse"')
  })
})

test_that("responsiveLayoutCollapseStartOpen option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = 2, c = 3)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      responsiveLayout = "collapse",
      responsiveLayoutCollapseStartOpen = FALSE
    )
    json <- isolate(renderer())

    expect_match(json, '"responsiveLayoutCollapseStartOpen"\\s*:\\s*false')
  })
})

# =============================================================================
# VIRTUAL DOM AND PROGRESSIVE RENDERING
# =============================================================================

test_that("renderVertical option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:100)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      renderVertical = "virtual"
    )
    json <- isolate(renderer())

    expect_match(json, '"renderVertical"\\s*:\\s*"virtual"')
  })
})

test_that("renderHorizontal option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = 2, c = 3, d = 4, e = 5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      renderHorizontal = "virtual"
    )
    json <- isolate(renderer())

    expect_match(json, '"renderHorizontal"\\s*:\\s*"virtual"')
  })
})

# =============================================================================
# PLACEHOLDER OPTIONS
# =============================================================================

test_that("placeholder option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = integer())
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      placeholder = "No data available"
    )
    json <- isolate(renderer())

    expect_match(json, '"placeholder"\\s*:\\s*"No data available"')
  })
})

# =============================================================================
# MOVABLE COLUMNS AND ROWS
# =============================================================================

test_that("movableColumns option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = 2, c = 3)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      movableColumns = TRUE
    )
    json <- isolate(renderer())

    expect_match(json, '"movableColumns"\\s*:\\s*true')
  })
})

test_that("movableRows option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:5)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      movableRows = TRUE
    )
    json <- isolate(renderer())

    expect_match(json, '"movableRows"\\s*:\\s*true')
  })
})

# =============================================================================
# INDEX COLUMN
# =============================================================================

test_that("index option works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = c("Alice", "Bob"))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      index = "name"
    )
    json <- isolate(renderer())

    expect_match(json, '"index"\\s*:\\s*"name"')
  })
})

# =============================================================================
# COMBINING OPTIONS WITH .opts
# =============================================================================

test_that(".opts parameter merges correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:20)
    rv <- reactiveVal(df)

    common_opts <- list(
      pagination = TRUE,
      paginationSize = 10,
      height = "400px"
    )

    renderer <- renderTabulatoR(
      rv(),
      .opts = common_opts
    )
    json <- isolate(renderer())

    expect_match(json, '"pagination"\\s*:\\s*true')
    expect_match(json, '"paginationSize"\\s*:\\s*10')
    expect_match(json, '"height"\\s*:\\s*"400px"')
  })
})

test_that("combining options with ... and .opts", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(x = 1:20)
    rv <- reactiveVal(df)

    common_opts <- list(
      pagination = TRUE,
      height = "400px"
    )

    # Add additional option via ...
    renderer <- renderTabulatoR(
      rv(),
      paginationSize = 25,
      .opts = common_opts
    )
    json <- isolate(renderer())

    # Should have both .opts values
    expect_match(json, '"pagination"\\s*:\\s*true')
    expect_match(json, '"height"\\s*:\\s*"400px"')

    # And the ... value
    expect_match(json, '"paginationSize"\\s*:\\s*25')
  })
})

# =============================================================================
# COMPREHENSIVE SNAPSHOT TEST
# =============================================================================

test_that("complex configuration with multiple options snapshot", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    # Use static data for reproducible snapshot
    df <- data.frame(
      id = 1:10,
      name = paste0("Person ", 1:10),
      dept = rep(c("Sales", "Engineering", "HR"), length.out = 10),
      age = seq(25, 52, length.out = 10),
      status = rep(c("active", "inactive"), length.out = 10),
      stringsAsFactors = FALSE
    )

    rv <- reactiveVal(df)

    cols <- c(
      Column("ID", "id", width = "60px"),
      Column("Name", "name", editor = "input"),
      Column("Department", "dept"),
      Column("Age", "age", hozAlign = "right"),
      Column("Status", "status")
    )

    renderer <- renderTabulatoR(
      rv(),
      columns = cols,
      layout = "fitColumns",
      height = "400px",
      pagination = TRUE,
      paginationSize = 10,
      paginationSizeSelector = c(10, 25, 50),
      initialSort = list(
        list(column = "name", dir = "asc")
      ),
      groupBy = "dept",
      groupStartOpen = TRUE,
      selectable = TRUE,
      tooltips = TRUE,
      movableColumns = TRUE,
      responsiveLayout = "collapse"
    )

    json <- isolate(renderer())

    # Snapshot complete payload
    expect_snapshot_json(json)
  })
})
