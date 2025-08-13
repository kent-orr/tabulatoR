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
