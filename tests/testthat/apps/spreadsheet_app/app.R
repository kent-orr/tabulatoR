library(shiny)

# Load package from source for testing
# This is needed because shinytest2 runs in a separate R process
if (!requireNamespace("tabulatoR", quietly = TRUE)) {
  pkgload::load_all("../../../..", quiet = TRUE)
}

ui <- fluidPage(
    titlePanel("Spreadsheet CRUD Test"),

    # Action buttons for testing
    actionButton("load_data", "Load Data"),
    actionButton("clear_sheet", "Clear Sheet"),
    actionButton("get_data", "Get Data"),

    br(), br(),

    # Spreadsheet output
    spreadsheetOutput("sheet", height = "400px"),

    br(),

    # Display status and data
    verbatimTextOutput("status"),
    verbatimTextOutput("current_data")
)

server <- function(input, output, session) {
    # Status message
    status <- reactiveVal("Ready")

    # Initial empty spreadsheet
    output$sheet <- renderSpreadsheet(
        data.frame(
            A = numeric(0),
            B = numeric(0),
            C = numeric(0)
        ),
        rows = 10,
        columns = 5,
        editable = TRUE
    )

    # Load sample data
    observeEvent(input$load_data, {
        spreadsheetSetData("sheet", data.frame(
            A = 1:5,
            B = 6:10,
            C = 11:15
        ))
        status("Data loaded")
    })

    # Clear spreadsheet
    observeEvent(input$clear_sheet, {
        spreadsheetClearSheet("sheet")
        status("Sheet cleared")
    })

    # Get current data
    observeEvent(input$get_data, {
        spreadsheetGetData("sheet")
        status("Data requested")
    })

    # Display status
    output$status <- renderPrint({
        cat("Status:", status(), "\n")
    })

    # Display retrieved data
    output$current_data <- renderPrint({
        if (!is.null(input$sheet_data)) {
            cat("Retrieved data:\n")
            print(input$sheet_data)
        } else {
            cat("No data retrieved yet")
        }
    })
}

shinyApp(ui, server)
