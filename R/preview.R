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
#' operations on a Tabulator table. A `verbatimTextOutput` displays the Shiny
#' inputs emitted by the table when rows are edited or clicked.
#'
#' The app is shown in Shiny's showcase mode so the underlying code is visible.
#'
#' @return A `shiny.appobj` object.
#' @examples
#' if (interactive()) {
#'     preview_crud()
#' }
#' @export
preview_crud <- function() {
    ui <- shiny::fluidPage(
        shiny::actionButton("add_row", "Add Row"),
        shiny::fluidRow(
            shiny::column(
                width = 8,
                tabulatoROutput("crud_table")
            ),
            shiny::column(
                width = 4,
                shiny::verbatimTextOutput("crud_inputs")
            )
        )
    )

    server <- function(input, output, session) {
        data <- shiny::reactiveVal(head(mtcars))

        output$crud_table <- renderTabulatoR(
            data(),
            events = c("cellEdited", "rowClick"),
            editable = TRUE
        )

        shiny::observeEvent(input$add_row, {
            new_row <- data()[1, , drop = FALSE]
            new_row[] <- NA
            tabulatorAddData("crud_table", new_row, add_to = "bottom")
        })

        shiny::observeEvent(input$crud_table$rowClick$index, {
            idx <- input$crud_table$rowClick$index
            tabulatorRemoveRow("crud_table", idx)
        })

        output$crud_inputs <- shiny::renderPrint({
            input$crud_table
        })
    }

    shiny::shinyApp(ui, server, options = list(display.mode = "showcase"))
}
