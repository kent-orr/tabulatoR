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
