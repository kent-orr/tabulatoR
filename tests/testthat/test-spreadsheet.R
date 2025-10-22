test_that("to_array_of_arrays converts data.frame correctly", {
    df <- data.frame(
        A = c(1, 2, 3),
        B = c("a", "b", "c"),
        C = c(TRUE, FALSE, TRUE),
        stringsAsFactors = FALSE
    )

    result <- to_array_of_arrays(df)

    # Should be a list of lists
    expect_type(result, "list")
    expect_length(result, 3)

    # Each row should be a list
    expect_type(result[[1]], "list")
    expect_length(result[[1]], 3)

    # Check first row values
    expect_equal(result[[1]][[1]], 1)
    expect_equal(result[[1]][[2]], "a")
    expect_equal(result[[1]][[3]], TRUE)

    # Check second row values
    expect_equal(result[[2]][[1]], 2)
    expect_equal(result[[2]][[2]], "b")
    expect_equal(result[[2]][[3]], FALSE)

    # Should be unnamed
    expect_null(names(result))
})


test_that("to_array_of_arrays converts matrix correctly", {
    mat <- matrix(1:12, nrow = 3, ncol = 4)

    result <- to_array_of_arrays(mat)

    # Should be a list of lists
    expect_type(result, "list")
    expect_length(result, 3)

    # Each row should be a list
    expect_type(result[[1]], "list")
    expect_length(result[[1]], 4)

    # matrix(1:12, nrow=3, ncol=4) fills column-wise:
    #   [,1] [,2] [,3] [,4]
    # [1,]  1    4    7   10
    # [2,]  2    5    8   11
    # [3,]  3    6    9   12

    # Check first row values
    expect_equal(result[[1]], list(1, 4, 7, 10))

    # Check second row values
    expect_equal(result[[2]], list(2, 5, 8, 11))

    # Should be unnamed
    expect_null(names(result))
})


test_that("to_array_of_arrays handles empty data.frame", {
    df <- data.frame()

    result <- to_array_of_arrays(df)

    expect_type(result, "list")
    expect_length(result, 0)
})


test_that("to_array_of_arrays handles single row data.frame", {
    df <- data.frame(A = 1, B = 2, C = 3)

    result <- to_array_of_arrays(df)

    expect_type(result, "list")
    expect_length(result, 1)
    expect_equal(result[[1]], list(1, 2, 3))  # Names are removed
})


test_that("to_array_of_arrays accepts list of lists", {
    data <- list(
        list(1, 2, 3),
        list(4, 5, 6),
        list(7, 8, 9)
    )

    result <- to_array_of_arrays(data)

    # Should return as-is
    expect_identical(result, data)
})


test_that("to_array_of_arrays throws error for invalid input", {
    expect_error(
        to_array_of_arrays("not a data structure"),
        "data must be a data.frame, matrix, or list of lists"
    )

    expect_error(
        to_array_of_arrays(list(1, 2, 3)),  # list of scalars, not list of lists
        "data must be a data.frame, matrix, or list of lists"
    )
})


test_that("renderSpreadsheet returns a function", {
    renderer <- renderSpreadsheet(head(mtcars))

    expect_type(renderer, "closure")
})


test_that("renderSpreadsheet output includes spreadsheet configuration", {
    renderer <- renderSpreadsheet(
        data.frame(A = 1:3, B = 4:6)
    )

    # Execute the render function
    json_output <- renderer()

    # Parse the JSON (don't simplify data frames)
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Check spreadsheet options
    expect_true(result$options$spreadsheet)

    # Should have columns with field names
    expect_type(result$options$columns, "list")
    expect_length(result$options$columns, 2)
    expect_equal(result$options$columns[[1]]$field, "A")
    expect_equal(result$options$columns[[1]]$title, "A")
    expect_equal(result$options$columns[[2]]$field, "B")
    expect_equal(result$options$columns[[2]]$title, "B")

    # Should have data as list of objects
    expect_type(result$options$data, "list")
    expect_length(result$options$data, 3)

    # Check clipboard is enabled
    expect_true(result$options$clipboard)
})


test_that("renderSpreadsheet sets editable by default", {
    renderer <- renderSpreadsheet(data.frame(A = 1:3))

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Should have editor configured in columns
    expect_equal(result$options$columns[[1]]$editor, "input")
})


test_that("renderSpreadsheet respects editable=FALSE", {
    renderer <- renderSpreadsheet(
        data.frame(A = 1:3),
        editable = FALSE
    )

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Should not have editor when editable=FALSE
    expect_null(result$options$columns[[1]]$editor)
})


test_that("renderSpreadsheet configures range selection", {
    renderer <- renderSpreadsheet(
        data.frame(A = 1:3),
        selectableRange = TRUE
    )

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    expect_true(result$options$selectableRange)
    expect_true(result$options$selectableRangeColumns)
    expect_true(result$options$selectableRangeRows)
    expect_true(result$options$selectableRangeClearCells)
})


test_that("renderSpreadsheet accepts custom column definition", {
    renderer <- renderSpreadsheet(
        data.frame(A = 1:3),
        columnDefinition = list(editor = "number", validator = "numeric")
    )

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Custom column definition should be applied to columns
    expect_equal(result$options$columns[[1]]$editor, "number")
    expect_equal(result$options$columns[[1]]$validator, "numeric")
})


test_that("renderSpreadsheet merges user options correctly", {
    renderer <- renderSpreadsheet(
        data.frame(A = 1:3),
        options = list(
            layout = "fitData",
            height = "500px"
        )
    )

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    expect_equal(result$options$layout, "fitData")
    expect_equal(result$options$height, "500px")
})


test_that("renderSpreadsheet accepts events parameter", {
    renderer <- renderSpreadsheet(
        data.frame(A = 1:3),
        events = list(
            cellEdited = js("function(cell) { return cell.getValue(); }")
        )
    )

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    expect_type(result$events, "list")
    expect_true("cellEdited" %in% names(result$events))
})


test_that("spreadsheetOutput creates correct HTML structure", {
    output <- spreadsheetOutput("test_sheet")

    # spreadsheetOutput returns a tagList, not a single tag
    expect_s3_class(output, "shiny.tag.list")

    # Check that it contains the necessary elements
    output_html <- as.character(output)
    expect_true(grepl("test_sheet", output_html))
    expect_true(grepl("tabulator-output", output_html))
})


test_that("spreadsheetOutput accepts custom dimensions", {
    output <- spreadsheetOutput("test_sheet", width = "800px", height = "600px")

    output_html <- as.character(output)
    expect_true(grepl("width: 800px", output_html))
    expect_true(grepl("height: 600px", output_html))
})


test_that("renderSpreadsheet works with data.frame input", {
    # Simple test that renderSpreadsheet accepts data.frame
    df <- data.frame(A = 1:5, B = 6:10)

    renderer <- renderSpreadsheet(df)

    expect_type(renderer, "closure")

    json_output <- renderer()
    expect_true(is.character(json_output))
    expect_true(grepl("spreadsheet", json_output))
})


test_that("renderSpreadsheet converts mtcars correctly", {
    renderer <- renderSpreadsheet(head(mtcars, 3))

    json_output <- renderer()
    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Should have columns for all mtcars columns
    expect_type(result$options$columns, "list")
    expect_length(result$options$columns, 11)  # mtcars has 11 columns

    # Check first column has correct properties
    expect_equal(result$options$columns[[1]]$field, "mpg")
    expect_equal(result$options$columns[[1]]$title, "mpg")

    # Should have 3 rows of data
    expect_type(result$options$data, "list")
    expect_length(result$options$data, 3)
})


test_that("renderSpreadsheet handles NA values", {
    df <- data.frame(
        A = c(1, NA, 3),
        B = c(NA, "text", NA),
        stringsAsFactors = FALSE
    )

    renderer <- renderSpreadsheet(df)
    json_output <- renderer()

    # Check that JSON contains null for NA values
    expect_true(grepl('null', json_output))

    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Should have data with NA values preserved
    expect_type(result$options$data, "list")
    expect_length(result$options$data, 3)
})


test_that("renderSpreadsheet handles all numeric data", {
    mat <- matrix(1:20, nrow = 4, ncol = 5)

    renderer <- renderSpreadsheet(mat)
    json_output <- renderer()

    result <- jsonlite::fromJSON(json_output, simplifyDataFrame = FALSE)

    # Should have 5 columns from matrix
    expect_type(result$options$columns, "list")
    expect_length(result$options$columns, 5)

    # Should have 4 rows of data
    expect_type(result$options$data, "list")
    expect_length(result$options$data, 4)

    # Check that data is present (converted to data.frame first, so column names exist)
    expect_true(length(result$options$data[[1]]) > 0)
})
