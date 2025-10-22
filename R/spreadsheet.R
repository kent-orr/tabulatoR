#' Convert data.frame or matrix to array-of-arrays format
#'
#' @param data A data.frame or matrix to convert
#' @return A list of lists (array-of-arrays) suitable for Tabulator spreadsheet mode
#' @keywords internal
to_array_of_arrays <- function(data) {
    if (is.data.frame(data)) {
        if (nrow(data) == 0) {
            return(list())
        }
        # Convert each row to a list, removing names
        unname(lapply(seq_len(nrow(data)), function(i) {
            unname(as.list(data[i, ]))
        }))
    } else if (is.matrix(data)) {
        if (nrow(data) == 0) {
            return(list())
        }
        # Convert matrix rows to lists
        # Note: matrix[i,] returns a vector, so we convert it to a list
        unname(lapply(seq_len(nrow(data)), function(i) {
            unname(as.list(data[i, ]))
        }))
    } else if (is.list(data) && all(sapply(data, is.list))) {
        # Already in array-of-arrays format
        data
    } else {
        stop("data must be a data.frame, matrix, or list of lists")
    }
}


#' Render a Tabulator Spreadsheet in Shiny
#'
#' @description
#' Creates a reactive Tabulator spreadsheet widget for use in Shiny applications.
#' Spreadsheet mode provides an Excel-like interface with grid-based editing,
#' arrow key navigation, and clipboard support.
#'
#' This function uses column definitions to provide real column headers from your
#' data.frame or matrix column names, rather than generic A, B, C labels. Data is
#' stored as objects (named lists) which allows for field-based access and simpler
#' CRUD operations.
#'
#' This is a thin wrapper around Tabulator's spreadsheet mode. For complete documentation
#' of all available options and features, see the official Tabulator documentation:
#' \url{https://tabulator.info/docs/6.3/spreadsheet}
#'
#' @param expr A reactive expression that returns a `data.frame` or `matrix`.
#' @param editable Logical. If `TRUE` (default), cells can be edited.
#' @param columnDefinition A list defining default properties for all columns.
#'                         For example, `list(editor = "input", validator = "numeric")`.
#'                         See \url{https://tabulator.info/docs/6.3/columns} for all column options.
#' @param selectableRange Logical. If `TRUE`, enables range selection with mouse/keyboard.
#'                        See \url{https://tabulator.info/docs/6.3/select#range}
#' @param clipboardPasteAction Character. Action to take when pasting data. Options:
#'                             "replace" (default) or "update".
#'                             See \url{https://tabulator.info/docs/6.3/clipboard}
#' @param events A named list of JS events that should be sent back to Shiny as input values.
#'               See \url{https://tabulator.info/docs/6.3/events} for all available events.
#' @param options A named list of additional Tabulator options to customize the spreadsheet.
#'                All Tabulator configuration options are supported.
#'                See \url{https://tabulator.info/docs/6.3/options}
#' @param ... Additional named elements to include in the payload passed to the front-end.
#' @param .opts A named list of additional payload entries, useful for programmatic inclusion.
#'              Elements in `...` will override matching keys in `.opts`.
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Logical. Is `expr` already quoted? If not, it will be quoted.
#'
#' @details
#' Spreadsheet mode differs from standard table mode in several ways:
#' - Column headers display actual data.frame/matrix column names
#' - Data is stored as objects with field names for easier access
#' - **Double-click** a cell to enter edit mode (or press Enter)
#' - Use **arrow keys** to navigate between cells
#' - Press **Tab** to move to the next cell
#' - Built-in support for copy/paste operations (Ctrl+C / Ctrl+V)
#' - Cannot use features like pagination, grouping, or tree structures
#'
#' The `editTriggerEvent` is set to "dblclick" by default for smoother navigation.
#' This allows you to click cells to select them and use arrow keys to navigate
#' without accidentally entering edit mode.
#'
#' JavaScript callbacks (such as event handlers) must be wrapped using `js()`
#' from this package to be interpreted as executable functions in the browser.
#'
#' @return A function that returns a list to be serialized and passed to the Tabulator output binding.
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     spreadsheetOutput("sheet")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$sheet <- renderSpreadsheet(
#'       head(mtcars),
#'       editable = TRUE,
#'       selectableRange = TRUE
#'     )
#'   }
#'
#'   shinyApp(ui, server)
#' }
renderSpreadsheet <- function(
    expr,
    editable = TRUE,
    columnDefinition = NULL,
    selectableRange = FALSE,
    clipboardPasteAction = "replace",
    events = NULL,
    options = list(),
    ...,
    .opts = list(),
    env = parent.frame(),
    quoted = FALSE) {

    func <- shiny::exprToFunction(expr, env, quoted)

    function() {
        data <- func()

        # Ensure we have a data.frame for column-based approach
        if (!is.data.frame(data)) {
            if (is.matrix(data)) {
                data <- as.data.frame(data)
            } else {
                stop("renderSpreadsheet requires a data.frame or matrix")
            }
        }

        # Generate column definitions from data.frame column names
        # This gives us real column headers instead of A, B, C
        columns <- lapply(seq_along(names(data)), function(i) {
            col_name <- names(data)[i]
            col_def <- list(
                title = col_name,
                field = col_name
            )

            # Add editor if editable
            if (editable) {
                if (!is.null(columnDefinition)) {
                    # Use user-provided column definition
                    col_def <- c(col_def, columnDefinition)
                } else {
                    # Default to input editor
                    col_def$editor <- "input"
                }
            }

            col_def
        })

        # Convert to object format (list of named lists)
        # Each row becomes a named list with field names
        data_list <- lapply(seq_len(nrow(data)), function(i) {
            as.list(data[i, , drop = FALSE])
        })

        # Build spreadsheet configuration with columns
        config <- list(
            spreadsheet = TRUE,
            columns = columns,
            data = data_list,
            # Set edit trigger to double-click for smoother navigation
            # This allows single-click to select and arrow keys to navigate
            # without accidentally entering edit mode
            editTriggerEvent = "dblclick",
            # Set empty cells to undefined to keep exports clean
            editorEmptyValue = NA
        )

        # Add range selection if requested
        if (selectableRange) {
            config$selectableRange <- TRUE
            config$selectableRangeColumns <- TRUE
            config$selectableRangeRows <- TRUE
            config$selectableRangeClearCells <- TRUE
        }

        # Add clipboard settings
        config$clipboard <- TRUE
        config$clipboardPasteAction <- clipboardPasteAction

        # Merge user options (user options override defaults)
        config <- c(config, options, .opts, list(...))

        payload <- list(
            options = config,
            events = events
        )

        htmlwidgets:::toJSON2(payload, auto_unbox = TRUE)
    }
}


#' Output element for a Tabulator spreadsheet
#'
#' @description
#' Creates an output element in the Shiny UI to display a Tabulator spreadsheet.
#' This should be paired with `renderSpreadsheet()` in the server function.
#'
#' @param outputId The output variable to read the spreadsheet from.
#' @param width The width of the spreadsheet container (default: "100%").
#' @param height The height of the spreadsheet container (default: "400px").
#' @param ... Additional arguments passed to `tab_source()` for customizing Tabulator version and theme.
#'
#' @return An HTML widget container for the spreadsheet.
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     spreadsheetOutput("my_spreadsheet", height = "600px")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$my_spreadsheet <- renderSpreadsheet(
#'       data.frame(
#'         A = 1:10,
#'         B = 11:20,
#'         C = 21:30
#'       )
#'     )
#'   }
#'
#'   shinyApp(ui, server)
#' }
spreadsheetOutput <- function(outputId, width = "100%", height = "400px", ...) {
    htmltools::tagList(
        htmltools::singleton(htmltools::tags$head(tab_source(...))),
        htmltools::tags$div(
            id = outputId,
            class = "tabulator-output",
            style = sprintf("width: %s; height: %s;", width, height)
        )
    )
}
