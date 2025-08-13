
library(shiny)
library(tabulatoR)

# Tests for CRUD operations

test_that("tabulatorAddData appends rows and triggers rowAdded input", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        observed <- reactiveVal(NULL)
        observeEvent(input$tbl, observed(input$tbl))
        tabulatorAddData("tbl", data.frame(id = 3), session = session)
        msg <- session$getLastCustomMessage()
        expect_equal(msg$type, "tabulator-add-data")
        expect_equal(msg$message$id, "tbl")
        expect_equal(msg$message$data[[1]]$id, 3)
        session$setInputs(tbl = list(action = "rowAdded", row = list(id = 3)))
        expect_equal(observed()$action, "rowAdded")
        expect_equal(observed()$row$id, 3)
    })
})

test_that("tabulatorReplaceData updates rows and triggers cellEdited input", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        observed <- reactiveVal(NULL)
        observeEvent(input$tbl, observed(input$tbl))
        tabulatorReplaceData("tbl", data.frame(id = 1, name = "Alice"), session = session)
        msg <- session$getLastCustomMessage()
        expect_equal(msg$type, "tabulator-replace-data")
        expect_equal(msg$message$id, "tbl")
        expect_equal(msg$message$data[[1]]$name, "Alice")
        session$setInputs(tbl = list(action = "cellEdited", field = "name", value = "Alice", old_value = "Bob", row = list(id = 1, name = "Alice"), index = 1))
        expect_equal(observed()$action, "cellEdited")
        expect_equal(observed()$field, "name")
        expect_equal(observed()$value, "Alice")
        expect_equal(observed()$old_value, "Bob")
    })
})

test_that("tabulatorRemoveRow deletes rows and triggers rowDeleted input", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        observed <- reactiveVal(NULL)
        observeEvent(input$tbl, observed(input$tbl))
        tabulatorRemoveRow("tbl", index = 1, session = session)
        msg <- session$getLastCustomMessage()
        expect_equal(msg$type, "tabulator-remove-row")
        expect_equal(msg$message$id, "tbl")
        expect_equal(msg$message$index, 1)
        session$setInputs(tbl = list(action = "rowDeleted", row = list(id = 1)))
        expect_equal(observed()$action, "rowDeleted")
        expect_equal(observed()$row$id, 1)
    })
})

test_that("Reading data emits cellClick input without altering table", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        observed <- reactiveVal(NULL)
        observeEvent(input$tbl, observed(input$tbl))
        expect_null(session$getLastCustomMessage())
        session$setInputs(tbl = list(action = "cellClick", field = "name", value = "Alice", row = list(id = 1, name = "Alice"), index = 1))
        expect_equal(observed()$action, "cellClick")
        expect_equal(observed()$field, "name")
        expect_equal(observed()$value, "Alice")
        expect_equal(observed()$row$name, "Alice")
    })
})

