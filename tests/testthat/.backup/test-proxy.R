test_that("tabulatorReplaceData sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    data <- data.frame(a = 1:2, b = c("x", "y"))
    tabulatorReplaceData("my_id", data, session)
    expect_snapshot(messages[["tabulator-replace-data"]])
})


test_that("tabulatorAddData sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    data <- data.frame(a = 3:4)
    tabulatorAddData("tbl", data, add_to = "bottom", session = session)
    expect_snapshot(messages[["tabulator-add-data"]])
})


test_that("tabulatorRemoveRow sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    tabulatorRemoveRow("tbl", 5, session)
    expect_snapshot(messages[["tabulator-remove-row"]])
})


test_that("tabulatorRestoreOldValue sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    tabulatorRestoreOldValue("tbl", 2, "field", session)
    expect_snapshot(messages[["tabulator-restore-old-value"]])
})
