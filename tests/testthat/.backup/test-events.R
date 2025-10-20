library(tabulatoR)
library(shiny)
library(shinytest2)

test_that("default event handlers are defined", {
    js_file <- system.file("tabulatoR.js", package = "tabulatoR")
    js_lines <- readLines(js_file)
    start <- grep("const defaultEventHandlers = \\{", js_lines)
    end <- start + which(js_lines[start:length(js_lines)] == "};")[1] - 1
    block <- js_lines[(start + 1):end]
    keys <- sub("^\\s*([a-zA-Z0-9]+):.*", "\\1", block[grepl("^[\\s]*[a-zA-Z0-9]+:", block)])
    expect_setequal(
        keys,
        c("cellClick", "cellEdited", "validationFailed", "rowAdded", "rowDeleted")
    )
})

test_that("renderTabulatoR serializes custom event handlers", {
    session <- shiny::MockShinySession$new()
    shiny::withReactiveDomain(session, {
        rv <- reactiveVal(data.frame(a = 1))
        custom <- renderTabulatoR(rv(), events = list(
            cellClick = js("function(){ return { action: 'custom' }; }")
        ))
        json <- shiny::isolate(custom())
        payload <- jsonlite::fromJSON(json)
        expect_true("cellClick" %in% names(payload$events))
        expect_match(payload$events$cellClick, "^<js>function")
    })
})

test_that("user event handlers override defaults in binding", {
    js_file <- system.file("tabulatoR.js", package = "tabulatoR")
    js_lines <- readLines(js_file)
    merge_line <- js_lines[grep("const mergedEvents", js_lines)]
    expect_true(grepl("...defaultEventHandlers, ...userEvents", merge_line, fixed = TRUE))
})

test_that("custom event handlers are flattened automatically", {
    app <- AppDriver$new(
        app_dir = test_path("..", "custom-handler-app"),
        name = "custom-handler",
        variant = platform_variant(),
        seed = 123
    )
    on.exit(app$stop())

    app$wait_for_js("window.tbl !== undefined")
    app$run_js("window.tbl.getRows()[0].getCell('a')._cell.click();")
    app$wait_for_value(input = "tbl")
    val <- app$get_value(input = "tbl")
    expect_equal(val$nested, 1)
})
