library(shiny)
# library(tabulatoR)
testthat::skip_if_not_installed("shinytest2")
library(shinytest2)


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
                tabulatorAddData("tbl", data.frame(id = 3, name = "Charlie"))
            })

            observeEvent(input$replace, {
                tabulatorReplaceData("tbl", data.frame(id = 1, name = "Alice"))
            })

            observeEvent(input$remove, {
                tabulatorRemoveRow("tbl", index = 1)
            })


        }
    )
}


test_that("tabulatorAddData appends rows to table", {
    app <- AppDriver$new(
        crud_app(),
        name = "crud-add",
        variant = platform_variant(),
        seed = 123
    )
    on.exit(app$stop())

    app$wait_for_js("window.tbl !== undefined", timeout = 5000)
    
    # Check initial data length
    initial_length <- app$get_js("window.tbl.getDataCount();")
    expect_equal(initial_length, 1)

    app$set_inputs(add = 'click')
    
    # Wait for data to be added and check new length
    app$wait_for_js("window.tbl.getData().length === 2", timeout = 5000)
    new_length <- app$get_js("window.tbl.getDataCount();")
    expect_equal(new_length, 2)
    
    # Check the added row data
    added_row <- app$get_js("window.tbl.getData()[1];")
    expect_equal(added_row$id[[1]], 3)
    expect_equal(added_row$name[[1]], "Charlie")
})

test_that("tabulatorReplaceData updates table data", {
    app <- AppDriver$new(crud_app())
    on.exit(app$stop())
    
    app$wait_for_js("window.tbl !== undefined", timeout = 5000)
    
    # Check initial data
    initial_data <- app$get_js("window.tbl.getData()[0];")
    expect_equal(initial_data$name[[1]], "Bob")
    
    app$set_inputs(replace = "click")
    
    # Wait for data to be replaced and check
    app$wait_for_js("window.tbl.getData()[0].name[0] === 'Alice'", timeout = 5000)
    updated_data <- app$get_js("window.tbl.getData()[0];")
    expect_equal(updated_data$name[[1]], "Alice")
    expect_equal(updated_data$id[[1]], 1)
})

test_that("tabulatorRemoveRow deletes row from table", {
    app <- AppDriver$new(crud_app())
    on.exit(app$stop())
    
    app$wait_for_js("window.tbl !== undefined", timeout = 5000)
    
    # Check initial data length
    initial_length <- app$get_js("window.tbl.getData().length;")
    expect_equal(initial_length, 1)
    
    app$set_inputs(remove = "click")
    
    # Wait for row to be removed and check new length
    app$wait_for_js("window.tbl.getDataCount() === 0", timeout = 5000)
    new_length <- app$get_js("window.tbl.getDataCount();")
    expect_equal(new_length, 0)
})

test_that("cellClick event is triggered and doesn't alter table", {
    app <- AppDriver$new(crud_app())
    on.exit(app$stop())
    
    app$wait_for_js("window.tbl !== undefined", timeout = 5000)

    app$get_values()
    
    # Get initial data
    initial_data <- app$get_js("window.tbl.getData();")
    initial_length <- length(initial_data)
    
    # Simulate clicking on the "name" cell in the first row
    app$run_js("
    const cell = window.tbl.getRows()[0].getCell('name');
    const event = new MouseEvent('click', { bubbles: true });
    cell.getElement().dispatchEvent(event);
    ")
    
    # Wait for the event to be processed
    app$wait_for_value(input = "tbl")
    evt <- app$get_value(input = "tbl")
    
    # Verify the event was received
    expect_equal(evt$action, "cellClick")
    expect_equal(evt$field, "name")
    expect_equal(evt$value, "Bob")  # Should be the original value
    
    # Verify table data unchanged
    final_data <- app$get_js("window.tbl.getData();")
    final_length <- length(final_data)
    expect_equal(final_length, initial_length)
})
