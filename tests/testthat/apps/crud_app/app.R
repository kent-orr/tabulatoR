library(shiny)

# Load package from source for testing
# This is needed because shinytest2 runs in a separate R process
if (!requireNamespace("tabulatoR", quietly = TRUE)) {
  pkgload::load_all("../../../..", quiet = TRUE)
}

ui <- fluidPage(
  titlePanel("TabulatoR CRUD Test App"),
  actionButton("add_row", "Add Row"),
  actionButton("delete_first_row", "Delete First Row"),
  fluidRow(
    column(
      width = 8,
      tabulatoROutput("crud_table")
    ),
    column(
      width = 4,
      h4("Latest Event:"),
      verbatimTextOutput("crud_inputs")
    )
  )
)

server <- function(input, output, session) {
  data <- reactiveVal(head(mtcars))

  output$crud_table <- renderTabulatoR(
    data(),
    autoColumns = FALSE,
    editable = TRUE,
    columns = lapply(colnames(mtcars), function(col) {
      Column(title = col, field = col, editor = "input")
    })
  )

  # Handle table events with a single observer
  observeEvent(input$crud_table, {
    event <- input$crud_table

    if (!is.null(event$action)) {
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

      if (event$action == "rowDeleted") {
        # Update the data when a row is deleted
        # Note: rowDeleted only provides the row data, not the index
        # For a proper implementation, you'd need to identify the row by a unique key
        # For this test app, we'll just acknowledge the event without updating
        message("Row deleted: ", paste(names(event$row), collapse = ", "))
      }
    }
  })

  # Add a new row when button is clicked
  observeEvent(input$add_row, {
    new_row <- data()[1, , drop = FALSE]
    new_row[] <- NA
    tabulatorAddRow("crud_table", new_row, add_to = "bottom")
  })

  # Delete the first row when button is clicked
  observeEvent(input$delete_first_row, {
    tabulatorRemoveRow("crud_table", 1)
  })

  # Display the latest event
  output$crud_inputs <- renderPrint({
    input$crud_table
  })
}

shinyApp(ui, server)
