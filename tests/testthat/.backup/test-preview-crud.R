library(tabulatoR)

testthat::skip_if_not_installed("shinytest2")
library(shinytest2)

test_that("preview_crud supports basic CRUD actions", {
    app <- AppDriver$new(preview_crud())
    on.exit(app$stop())

    app$wait_for_js("window.crud_table !== undefined", timeout = 5000)

    initial <- app$get_js("window.crud_table.getDataCount();")
    expect_equal(initial, 6)

    app$set_inputs(add_row = "click")
    app$wait_for_js("window.crud_table.getDataCount() === 7", timeout = 5000)

    app$run_js("
        const row = window.crud_table.getRows()[0];
        row.getElement().dispatchEvent(new MouseEvent('click', {bubbles: true}));
    ")

    app$wait_for_js("window.crud_table.getDataCount() === 6", timeout = 5000)
})
