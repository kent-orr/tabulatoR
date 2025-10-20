library(tabulatoR)

testthat::skip_if_not_installed("shinytest2")
library(shinytest2)

test_that("preview_static renders data", {
    app <- AppDriver$new(preview_static())
    on.exit(app$stop())

    app$wait_for_js("window.static_table !== undefined", timeout = 5000)
    rows <- app$get_js("window.static_table.getDataCount();")
    expect_equal(rows, 6)
})

