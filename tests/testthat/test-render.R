library(shiny)

expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

test_that("renderTabulatoR generates expected payload", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    rv <- reactiveVal(data.frame(a = 1:2, b = c("x", "y")))
    render_fun <- renderTabulatoR(rv())
    json <- shiny::isolate(render_fun())
    expect_snapshot_json(json)
  })
})

test_that("flatten_columns handles empty input", {
    expect_equal(flatten_columns(c()), c())
    expect_equal(flatten_columns(list()), list())
})

test_that("flatten_columns handles lists with c()", {
    # What works (using c())
    c_columns <- c(Column("A", "a"), Column("B", "b"))
    
    # What doesn't work (using list())
    list_columns <- list(Column("A", "a"), Column("B", "b"))
    
    # flatten_columns should make list_columns equivalent to c_columns
    result <- flatten_columns(list_columns)
    expect_equal(result, c_columns)
    expect_null(names(result))
    
    # Verify JSON serialization is identical
    expect_equal(
        jsonlite::toJSON(result, auto_unbox = TRUE),
        jsonlite::toJSON(c_columns, auto_unbox = TRUE)
    )
})

test_that("flatten_columns handles already flat column lists", {
    flat_columns <- list(
        list(title = "A", field = "a"),
        list(title = "B", field = "b")
    )
    result <- flatten_columns(flat_columns)
    expect_equal(result, flat_columns)
    expect_null(names(result))
})