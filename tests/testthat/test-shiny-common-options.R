library(tabulatoR)
library(shiny)
library(testthat)

# =============================================================================
# SHINY COMMON OPTIONS TESTS
# =============================================================================
# These tests verify that common Tabulator options work correctly in Shiny.

test_that("pagination options work in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      pagination = TRUE,
      paginationSize = 2,
      paginationSizeSelector = c(2, 5, 10)
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$pagination, TRUE)
    expect_equal(payload$options$paginationSize, 2)
    expect_equal(payload$options$paginationSizeSelector, list(2, 5, 10))
  })
})

test_that("selectable option works in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), selectable = 1)
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$selectable, 1)
  })
})

test_that("movableRows option works in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), movableRows = TRUE)
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$movableRows, TRUE)
  })
})

test_that("height option works in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(data_rv(), height = "400px")
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$height, "400px")
  })
})

test_that("layout options work in Shiny", {
  layouts <- c("fitData", "fitColumns", "fitDataFill")

  for (layout in layouts) {
    session <- MockShinySession$new()
    withReactiveDomain(session, {
      data_rv <- reactive(sample_data())
      renderer <- renderTabulatoR(data_rv(), layout = layout)
      json <- isolate(renderer())
      payload <- parse_payload(json)

      expect_equal(payload$options$layout, layout)
    })
  }
})

test_that("placeholder option works in Shiny", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(empty_data())
    renderer <- renderTabulatoR(
      data_rv(),
      placeholder = "No data available"
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$placeholder, "No data available")
  })
})

test_that("multiple options combine correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      pagination = TRUE,
      paginationSize = 3,
      selectable = 1,
      movableRows = TRUE,
      layout = "fitData",
      height = "350px"
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_equal(payload$options$pagination, TRUE)
    expect_equal(payload$options$paginationSize, 3)
    expect_equal(payload$options$selectable, 1)
    expect_equal(payload$options$movableRows, TRUE)
    expect_equal(payload$options$layout, "fitData")
    expect_equal(payload$options$height, "350px")
  })
})

test_that("reactive data updates preserve options", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactiveVal(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      pagination = TRUE,
      paginationSize = 2,
      selectable = 1
    )

    # Get initial options
    json1 <- isolate(renderer())
    payload1 <- parse_payload(json1)

    # Update data
    data_rv(single_row_data())

    # Get updated options
    json2 <- isolate(renderer())
    payload2 <- parse_payload(json2)

    # Options should be preserved
    expect_equal(payload2$options$pagination, TRUE)
    expect_equal(payload2$options$paginationSize, 2)
    expect_equal(payload2$options$selectable, 1)
  })
})
