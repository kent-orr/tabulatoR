#' Preview a static Tabulator table
#'
#' Launches a minimal Shiny application showing a non-editable Tabulator table.
#' This can be used to quickly preview the package output or within automated tests.
#'
#' @return A `shiny.appobj` object.
#' @examples
#' if (interactive()) {
#'     preview_static()
#' }
#' @export
preview_static <- function() {
    ui <- shiny::fluidPage(
        tabulatoROutput("static_table")
    )

    server <- function(input, output, session) {
        output$static_table <- renderTabulatoR(head(mtcars), editable = FALSE)
    }

    shiny::shinyApp(ui, server)
}

#' Preview a Tabulator table with basic CRUD
#'
#' Launches a Shiny application demonstrating create, read, update and delete
#' operations on a Tabulator table. Rows can be edited directly in the table,
#' and users can add rows via a button. A `verbatimTextOutput` displays the
#' Shiny input events emitted by the table when rows are edited.
#'
#' This example demonstrates the recommended pattern for handling Tabulator events:
#' use a single `observeEvent(input$table, {...})` and branch based on the `action` field.
#'
#' @return A `shiny.appobj` object.
#' @examples
#' if (interactive()) {
#'     preview_crud()
#' }
#' @export
preview_crud <- function() {
    ui <- shiny::fluidPage(
        shiny::titlePanel("TabulatoR CRUD Demo"),
        shiny::actionButton("add_row", "Add Row"),
        shiny::fluidRow(
            shiny::column(
                width = 8,
                tabulatoROutput("crud_table")
            ),
            shiny::column(
                width = 4,
                shiny::h4("Latest Event:"),
                shiny::verbatimTextOutput("crud_inputs")
            )
        )
    )

    server <- function(input, output, session) {
        data <- shiny::reactiveVal(head(mtcars))

        output$crud_table <- renderTabulatoR(
            data(),
            autoColumns = FALSE,
            editable = TRUE,
            columns = lapply(colnames(mtcars), function(col) {
                Column(title = col, field = col, editor = "input")
            })
        )

        # Handle table events with a single observer
        shiny::observeEvent(input$crud_table, {
            event <- input$crud_table

            if (event$action == "cellEdited") {
                # Update the data when a cell is edited
                current_data <- data()
                current_data[event$index, event$field] <- event$value
                data(current_data)
            }

            if (event$action == "rowAdded") {
                # Update the data when a row is added
                data(rbind(data(), event$row))
            }
        })

        # Add a new row when button is clicked
        shiny::observeEvent(input$add_row, {
            new_row <- data()[1, , drop = FALSE]
            new_row[] <- NA
            tabulatorAddRow("crud_table", new_row, add_to = "bottom")
        })

        # Display the latest event
        output$crud_inputs <- shiny::renderPrint({
            input$crud_table
        })
    }

    shiny::shinyApp(ui, server)
}


#' Preview a Tabulator spreadsheet
#'
#' Launches a Shiny application demonstrating spreadsheet functionality with
#' Excel-like grid editing, arrow key navigation, and data manipulation via proxy
#' functions. Users can edit cells, load new data, and clear the spreadsheet.
#'
#' This example demonstrates:
#' - Spreadsheet mode with editable cells
#' - Arrow key navigation and Enter to edit
#' - Proxy functions: `spreadsheetSetData()` and `spreadsheetClearSheet()`
#' - Range selection for copy/paste operations
#' - Event handling for cell edits
#'
#' @return A `shiny.appobj` object.
#' @examples
#' if (interactive()) {
#'     preview_spreadsheet()
#' }
#' @export
preview_spreadsheet <- function() {
    ui <- shiny::fluidPage(
        shiny::titlePanel("TabulatoR Spreadsheet Demo"),
        shiny::fluidRow(
            shiny::column(
                width = 12,
                shiny::h4("Spreadsheet Controls"),
                shiny::actionButton("load_mtcars", "Load mtcars Data"),
                shiny::actionButton("load_random", "Load Random Data"),
                shiny::actionButton("clear_sheet", "Clear Spreadsheet"),
                shiny::actionButton("get_data", "Get Current Data"),
                shiny::hr()
            )
        ),
        shiny::fluidRow(
            shiny::column(
                width = 8,
                shiny::h4("Spreadsheet"),
                spreadsheetOutput("spreadsheet", height = "500px")
            ),
            shiny::column(
                width = 4,
                shiny::h4("Status & Events"),
                shiny::verbatimTextOutput("status"),
                shiny::h5("Latest Event:"),
                shiny::verbatimTextOutput("event_log"),
                shiny::h5("Retrieved Data:"),
                shiny::verbatimTextOutput("retrieved_data")
            )
        ),
        shiny::fluidRow(
            shiny::column(
                width = 12,
                shiny::hr(),
                shiny::h5("Instructions:"),
                shiny::tags$ul(
                    shiny::tags$li("Click a cell to select it"),
                    shiny::tags$li(shiny::strong("Double-click"), " a cell to enter edit mode (or press Enter)"),
                    shiny::tags$li("Use arrow keys to navigate between cells"),
                    shiny::tags$li("Press Tab to move to the next cell"),
                    shiny::tags$li("Select cells and use Ctrl+C/Ctrl+V to copy/paste"),
                    shiny::tags$li("Use the buttons above to test proxy functions")
                )
            )
        )
    )

    server <- function(input, output, session) {
        status <- shiny::reactiveVal("Ready - spreadsheet initialized")

        # Initial spreadsheet with sample data
        output$spreadsheet <- renderSpreadsheet(
            data.frame(
                Col1 = 1:10,
                Col2 = 11:20,
                Col3 = 21:30,
                Col4 = 31:40,
                Col5 = 41:50
            ),
            rows = 20,
            columns = 10,
            selectableRange = TRUE,
            editable = TRUE
        )

        # Load mtcars data
        shiny::observeEvent(input$load_mtcars, {
            spreadsheetSetData("spreadsheet", head(mtcars, 10))
            status("Loaded mtcars data (first 10 rows)")
        })

        # Load random data
        shiny::observeEvent(input$load_random, {
            random_data <- data.frame(
                A = sample(1:100, 15),
                B = sample(1:100, 15),
                C = sample(1:100, 15),
                D = sample(1:100, 15),
                E = sample(1:100, 15)
            )
            spreadsheetSetData("spreadsheet", random_data)
            status("Loaded random data (15 rows, 5 columns)")
        })

        # Clear spreadsheet
        shiny::observeEvent(input$clear_sheet, {
            spreadsheetClearSheet("spreadsheet")
            status("Spreadsheet cleared")
        })

        # Request current data
        shiny::observeEvent(input$get_data, {
            spreadsheetGetData("spreadsheet")
            status("Data retrieval requested - check 'Retrieved Data' below")
        })

        # Display status
        output$status <- shiny::renderPrint({
            status()
        })

        # Display latest event
        output$event_log <- shiny::renderPrint({
            if (!is.null(input$spreadsheet)) {
                input$spreadsheet
            } else {
                "No events yet"
            }
        })

        # Display retrieved data
        output$retrieved_data <- shiny::renderPrint({
            if (!is.null(input$spreadsheet_data)) {
                str(input$spreadsheet_data)
            } else {
                "No data retrieved yet - click 'Get Current Data'"
            }
        })
    }

    shiny::shinyApp(ui, server)
}
