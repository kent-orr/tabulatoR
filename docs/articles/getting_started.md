# Getting Started with tabulatoR

``` r
library(tabulatoR)
library(shiny)
```

## Introduction

**tabulatoR** brings the powerful [Tabulator JavaScript
library](https://tabulator.info/) to Shiny applications, providing
interactive, customizable data tables with minimal code. This vignette
will guide you through creating basic tables and implementing editing
functionality.

### Creating a Simple Static Table

Let’s start with a basic example using the built-in `mtcars` dataset:

``` r
library(shiny)
library(tabulatoR)

ui <- fluidPage(
  titlePanel("Basic Tabulator Table"),
  tabulatoROutput("my_table", height = "500px")
)

server <- function(input, output, session) {
  output$my_table <- renderTabulatoR({
    # Use a subset of mtcars for clarity
    data <- head(mtcars, 10)
    data
  })
}

shinyApp(ui, server)
```

This creates a fully functional table with auto-generated columns. By
default,
[`renderTabulatoR()`](https://kent-orr.github.io/tabulatoR/reference/renderTabulatoR.md)
sets `autoColumns = TRUE`, which automatically creates columns based on
your dataframe structure.

#### Customizing Column Definitions

For more control over your table’s appearance and behavior, you can
define columns explicitly using the
[`Column()`](https://kent-orr.github.io/tabulatoR/reference/Column.md)
helper function:

``` r
ui <- fluidPage(
  titlePanel("Customized Table"),
  tabulatoROutput("cars_table", height = "500px")
)

server <- function(input, output, session) {
  output$cars_table <- renderTabulatoR({
    x = head(mtcars, 10)
    x$rowname = row.names(x)
    x
  },
  columns = c(
    Column(title = "Car Model", field = "rowname"),
    Column(title = "MPG", field = "mpg", hozAlign = "center"),
    Column(title = "Cylinders", field = "cyl", hozAlign = "center"),
    Column(title = "Horsepower", field = "hp", hozAlign = "right"),
    Column(title = "Weight", field = "wt", hozAlign = "right")
  ),
  autoColumns = FALSE,
  editable = FALSE
  )
}

shinyApp(ui, server)
```

### Basic Editing (No Backend CRUD)

One of tabulatoR’s key features is enabling inline editing. Let’s create
an editable table where users can modify values directly:

``` r
ui <- fluidPage(
  titlePanel("Editable Table Example"),

  fluidRow(
    column(
      width = 8,
      tabulatoROutput("editable_table", height = "500px")
    ),
    column(
      width = 4,
      h4("Table Data"),
      verbatimTextOutput("current_data")
    )
  )
)

server <- function(input, output, session) {
  # Store table data in a reactive value
  table_data <- reactiveVal(data.frame(
    id = 1:5,
    name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    age = c(25, 30, 35, 28, 32),
    department = c("Sales", "Engineering", "Marketing", "Sales", "Engineering"),
    stringsAsFactors = FALSE
  ))

  output$editable_table <- renderTabulatoR({
    table_data()
  },
  columns = c(
    Column(title = "ID", field = "id", editable = FALSE),
    Column(title = "Name", field = "name", editor = "input"),
    Column(title = "Age", field = "age", editor = "number"),
    Column(
      title = "Department",
      field = "department",
      editor = "select",
      editorParams = list(values = c("Sales", "Engineering", "Marketing", "HR"))
    )
  ),
  autoColumns = FALSE
  )

  # Display the current table data
  output$current_data <- renderPrint({
    table_data()
  })
}

shinyApp(ui, server)
```

This example demonstrates several editor types:

- **`editor = "input"`**: Basic text input for the Name column
- **`editor = "number"`**: Numeric input for the Age column
- **`editor = "select"`**: Dropdown selection for the Department column
  with predefined values
- **`editable = FALSE`**: The ID column is read-only

Note that while the table allows editing, changes are not yet persisted
back to the reactive data. We’ll address this in the next section.

### Handling Table Events with Shiny Observers

To make your editable table truly interactive, you need to respond to
user actions. tabulatoR sends table events back to Shiny through a
single reactive input.

#### Responding to Cell Edits

Here’s how to capture cell edits and update your data:

``` r
ui <- fluidPage(
  titlePanel("Interactive Editable Table"),

  fluidRow(
    column(
      width = 8,
      tabulatoROutput("interactive_table", height = "500px")
    ),
    column(
      width = 4,
      h4("Latest Event"),
      verbatimTextOutput("latest_event"),
      h4("Current Data"),
      verbatimTextOutput("current_data")
    )
  )
)

server <- function(input, output, session) {
  # Initialize reactive data
  table_data <- reactiveVal(data.frame(
    id = 1:5,
    name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    age = c(25, 30, 35, 28, 32),
    status = c("active", "active", "inactive", "active", "inactive"),
    notes = c("", "Team lead", "", "New hire", ""),
    stringsAsFactors = FALSE
  ))

  output$interactive_table <- renderTabulatoR({
    table_data()
  },
  columns = c(
    Column(title = "ID", field = "id", editable = FALSE, width = "60px"),
    Column(title = "Name", field = "name", editor = "input"),
    Column(title = "Age", field = "age", editor = "number",
           editorParams = list(min = 18, max = 100)),
    Column(
      title = "Status",
      field = "status",
      editor = "select",
      editorParams = list(values = c("active", "inactive", "pending"))
    ),
    Column(title = "Notes", field = "notes", editor = "textarea")
  ),
  autoColumns = FALSE
  )

  # Handle table events
  observeEvent(input$interactive_table, {
    event <- input$interactive_table

    # Check if this is a cellEdited event
    if (!is.null(event$action) && event$action == "cellEdited") {
      # Update the data
      current_data <- table_data()
      current_data[event$index, event$field] <- event$value
      table_data(current_data)
    }
  })

  # Display latest event for debugging
  output$latest_event <- renderPrint({
    input$interactive_table
  })

  # Display current data
  output$current_data <- renderPrint({
    table_data()
  })
}

shinyApp(ui, server)
```

#### Understanding Table Events

When a user interacts with the table, tabulatoR sends event objects to
Shiny via `input$<table_id>`. The event structure includes:

- **`action`**: The type of event (e.g., `"cellEdited"`, `"rowAdded"`,
  `"rowDeleted"`)
- **`index`**: The row index (1-based, matching R conventions)
- **`field`**: The column field name that was edited
- **`value`**: The new value after editing
- **`row`**: The complete row data (for row-level events)

#### Common Observer Patterns

Here are the typical patterns for handling table events:

##### 1. Cell Edited Observer

``` r
observeEvent(input$my_table, {
  event <- input$my_table

  if (!is.null(event$action) && event$action == "cellEdited") {
    # Update your reactive data
    current_data <- table_data()
    current_data[event$index, event$field] <- event$value
    table_data(current_data)

    # Optional: Save to database, log changes, etc.
    message(sprintf("Cell edited: Row %d, Field %s, New value: %s",
                    event$index, event$field, event$value))
  }
})
```

##### 2. Handling Multiple Event Types

``` r
observeEvent(input$my_table, {
  event <- input$my_table

  if (!is.null(event$action)) {
    if (event$action == "cellEdited") {
      # Handle cell edit
      message(sprintf("Row %d: %s changed to %s",
                      event$index, event$field, event$value))
    } else if (event$action == "rowAdded") {
      # Handle new row
      message("New row added")
    } else if (event$action == "rowDeleted") {
      # Handle row deletion
      message("Row deleted")
    }
  }
})
```

##### 3. Validation and Reverting Invalid Edits

``` r
observeEvent(input$my_table, {
  event <- input$my_table

  if (!is.null(event$action) && event$action == "cellEdited") {
    # Validate the new value
    if (event$field == "age" && (event$value < 18 || event$value > 100)) {
      showNotification("Age must be between 18 and 100", type = "error")
      # Revert the cell to its previous value
      tabulatorRevertField("my_table", event$index, event$field)
      return()
    }

    # Update data if validation passes
    current_data <- table_data()
    current_data[event$index, event$field] <- event$value
    table_data(current_data)
  }
})
```

### Next Steps

This vignette covered the basics of creating and editing tables with
tabulatoR. For more advanced features, see:

- **Advanced Editing**: Row addition/deletion, bulk operations, and CRUD
  integration
- **JavaScript Customization**: Custom formatters, cell renderers, and
  event handlers
- **Spreadsheet Mode**: Excel-like functionality with
  [`renderSpreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/renderSpreadsheet.md)
- **Styling and Theming**: Customizing table appearance

For complete documentation of all available options, refer to the
[Tabulator documentation](https://tabulator.info/docs/6.3).
