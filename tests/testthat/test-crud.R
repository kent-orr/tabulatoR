library(shiny)
library(tabulatoR)
testthat::skip_if_not_installed("shinytest2")
library(shinytest2)

test_that("tabulatorAddData appends rows and triggers rowAdded input", {
    app <- shinyApp(
        ui = tabulatoROutput("tbl"),
        server = function(input, output, session) {
            output$tbl <- renderTabulatoR(data.frame(id = 1))
            last_msg <- reactiveVal(NULL)
            exportTestValues(last_msg = last_msg(), evt = input$tbl)
            session$onFlushed(function() {
                tabulatorAddData("tbl", data.frame(id = 3))
                last_msg(session$getLastCustomMessage())
            }, once = TRUE)
        }
    )
    drv <- AppDriver$new(app, load_timeout = 5000, wait = FALSE)
    msg <- drv$get_value(export = "last_msg")
    expect_equal(msg$type, "tabulator-add-data")
    expect_equal(msg$message$id, "tbl")
    expect_equal(msg$message$data[[1]]$id, 3)
    drv$set_inputs(tbl = list(action = "rowAdded", row = list(id = 3)))
    evt <- drv$get_value(input = "tbl")
    expect_equal(evt$action, "rowAdded")
    expect_equal(evt$row$id, 3)
    drv$stop()
})

test_that("tabulatorReplaceData updates rows and triggers cellEdited input", {
    app <- shinyApp(
        ui = tabulatoROutput("tbl"),
        server = function(input, output, session) {
            output$tbl <- renderTabulatoR(data.frame(id = 1, name = "Bob"))
            last_msg <- reactiveVal(NULL)
            exportTestValues(last_msg = last_msg())
            session$onFlushed(function() {
                tabulatorReplaceData("tbl", data.frame(id = 1, name = "Alice"))
                last_msg(session$getLastCustomMessage())
            }, once = TRUE)
        }
    )
    drv <- AppDriver$new(app, load_timeout = 5000, wait = FALSE)
    msg <- drv$get_value(export = "last_msg")
    expect_equal(msg$type, "tabulator-replace-data")
    expect_equal(msg$message$id, "tbl")
    expect_equal(msg$message$data[[1]]$name, "Alice")
    drv$set_inputs(tbl = list(action = "cellEdited", field = "name", value = "Alice", old_value = "Bob", row = list(id = 1, name = "Alice"), index = 1))
    evt <- drv$get_value(input = "tbl")
    expect_equal(evt$action, "cellEdited")
    expect_equal(evt$field, "name")
    expect_equal(evt$value, "Alice")
    expect_equal(evt$old_value, "Bob")
    drv$stop()
})

test_that("tabulatorRemoveRow deletes rows and triggers rowDeleted input", {
    app <- shinyApp(
        ui = tabulatoROutput("tbl"),
        server = function(input, output, session) {
            output$tbl <- renderTabulatoR(data.frame(id = 1))
            last_msg <- reactiveVal(NULL)
            exportTestValues(last_msg = last_msg())
            session$onFlushed(function() {
                tabulatorRemoveRow("tbl", index = 1)
                last_msg(session$getLastCustomMessage())
            }, once = TRUE)
        }
    )
    drv <- AppDriver$new(app, load_timeout = 5000, wait = FALSE)
    msg <- drv$get_value(export = "last_msg")
    expect_equal(msg$type, "tabulator-remove-row")
    expect_equal(msg$message$id, "tbl")
    expect_equal(msg$message$index, 1)
    drv$set_inputs(tbl = list(action = "rowDeleted", row = list(id = 1)))
    evt <- drv$get_value(input = "tbl")
    expect_equal(evt$action, "rowDeleted")
    expect_equal(evt$row$id, 1)
    drv$stop()
})

test_that("Reading data emits cellClick input without altering table", {
    app <- shinyApp(
        ui = tabulatoROutput("tbl"),
        server = function(input, output, session) {
            output$tbl <- renderTabulatoR(data.frame(id = 1, name = "Alice"))
            exportTestValues(last_msg = session$getLastCustomMessage())
        }
    )
    drv <- AppDriver$new(app, load_timeout = 5000, wait = FALSE)
    msg <- drv$get_value(export = "last_msg")
    expect_null(msg)
    drv$set_inputs(tbl = list(action = "cellClick", field = "name", value = "Alice", row = list(id = 1, name = "Alice"), index = 1))
    evt <- drv$get_value(input = "tbl")
    expect_equal(evt$action, "cellClick")
    expect_equal(evt$field, "name")
    expect_equal(evt$value, "Alice")
    expect_equal(evt$row$name, "Alice")
    drv$stop()
})
