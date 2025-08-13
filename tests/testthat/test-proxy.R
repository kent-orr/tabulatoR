test_that("tabulatorReplaceData sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    data <- data.frame(a = 1:2, b = c("x", "y"))
    tabulatorReplaceData("my_id", data, session)
    expected_data <- unname(split(data, seq(nrow(data))))
    expect_equal(
        messages[["tabulator-replace-data"]],
        list(id = "my_id", data = expected_data)
    )
})


test_that("tabulatorAddData sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    data <- data.frame(a = 3:4)
    tabulatorAddData("tbl", data, add_to = "bottom", session = session)
    expected_data <- unname(split(data, seq(nrow(data))))
    expect_equal(
        messages[["tabulator-add-data"]],
        list(id = "tbl", data = expected_data, addToTop = FALSE)
    )
})


test_that("tabulatorRemoveRow sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    tabulatorRemoveRow("tbl", 5, session)
    expect_equal(
        messages[["tabulator-remove-row"]],
        list(id = "tbl", index = 5)
    )
})


test_that("tabulatorRestoreOldValue sends correct custom message", {
    session <- shiny::MockShinySession$new()
    messages <- list()
    session$sendCustomMessage <- function(type, message) {
        messages[[type]] <<- message
    }
    tabulatorRestoreOldValue("tbl", 2, "field", session)
    expect_equal(
        messages[["tabulator-restore-old-value"]],
        list(id = "tbl", index = 2, field = "field")
    )
})
