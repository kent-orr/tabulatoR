library(shiny)
library(shinytest2)
library(tabulatoR)

crud_app <- function() {
    shinyApp(
        ui = fluidPage(
            actionButton("add", "Add"),
            actionButton("replace", "Replace"),
            actionButton("remove", "Remove"),
            tabulatoROutput("tbl")
        ),
        server = function(input, output, session) {
            output$tbl <- renderTabulatoR(data.frame(id = 1, name = "Bob"))

            observeEvent(input$add, {
                tabulatorAddData("tbl", data.frame(id = 3), session = session)
            })

            observeEvent(input$replace, {
                tabulatorReplaceData("tbl", data.frame(id = 1, name = "Alice"), session = session)
            })

            observeEvent(input$remove, {
                tabulatorRemoveRow("tbl", 1, session = session)
            })
        }
    )
}

test_that("tabulatorAddData appends rows and triggers rowAdded input", {
    app <- AppDriver$new(
        crud_app(),
        name = "crud-add",
        variant = platform_variant(),
        seed = 123
    )
    on.exit(app$stop())

    app$wait_for_js("window.tbl !== undefined")

    app$set_inputs(add = 1)
    app$wait_for_value(input = "tbl")
    val <- app$get_value(input = "tbl")
    expect_equal(val$action, "rowAdded")
    expect_equal(val$row$id, 3)
})

test_that("tabulatorReplaceData updates rows and triggers cellEdited input", {
    app <- AppDriver$new(
        crud_app(),
        name = "crud-replace",
        variant = platform_variant(),
        seed = 123
    )
    on.exit(app$stop())

    app$wait_for_js("window.tbl !== undefined")

    app$set_inputs(replace = 1)
    app$wait_for_js("window.tbl.getData()[0].name === 'Alice'")
    app$run_js("window.tbl.getRows()[0].getCell('name').setValue('Alicia');")
    app$wait_for_value(input = "tbl")
    val <- app$get_value(input = "tbl")
    expect_equal(val$action, "cellEdited")
    expect_equal(val$field, "name")
    expect_equal(val$value, "Alicia")
    expect_equal(val$old_value, "Alice")
})

test_that("tabulatorRemoveRow deletes rows and triggers rowDeleted input", {
    app <- AppDriver$new(
        crud_app(),
        name = "crud-remove",
        variant = platform_variant(),
        seed = 123
    )
    on.exit(app$stop())

    app$wait_for_js("window.tbl !== undefined")

    app$set_inputs(remove = 1)
    app$wait_for_value(input = "tbl")
    val <- app$get_value(input = "tbl")
    expect_equal(val$action, "rowDeleted")
    expect_equal(val$row$id, 1)
})

