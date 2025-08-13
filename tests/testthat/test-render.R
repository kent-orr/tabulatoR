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

test_that("renderTabulatoR handles list column inputs", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        columns_list <- list(
            Column("A", "a"),
            Column("B", "b")
        )
        rv <- reactiveVal(data.frame(a = 1, b = 2))
        render_fun <- renderTabulatoR(rv(), columns = columns_list, autoColumns = FALSE)
        json <- shiny::isolate(render_fun())
        expect_match(json, '\"columns\":\[')
        parsed <- jsonlite::fromJSON(json)
        expect_length(parsed$options$columns, 2)
        expect_null(names(parsed$options$columns))
    })
})

test_that("renderTabulatoR flattens nested Column lists", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        nested_columns <- list(
            list(Column("A", "a")),
            Column("B", "b")
        )
        rv <- reactiveVal(data.frame(a = 1, b = 2))
        render_fun <- renderTabulatoR(rv(), columns = nested_columns, autoColumns = FALSE)
        json <- shiny::isolate(render_fun())
        parsed <- jsonlite::fromJSON(json)
        expect_length(parsed$options$columns, 2)
        expect_null(names(parsed$options$columns))
    })
})
