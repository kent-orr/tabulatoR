# javascript

``` r
library(tabulatoR)
```

## Overview: How tabulatoR Wraps Tabulator.js

tabulatoR provides a lightweight R interface to the powerful
[Tabulator](http://tabulator.info/) JavaScript library. Unlike
traditional htmlwidgets-based packages, tabulatoR uses a custom Shiny
output binding with direct JSON serialization via `jsonlite`, giving you
clean, predictable output and full access to Tabulator’s extensive API.

### Architecture

The integration consists of three main components:

1.  **R functions**
    ([render.R](https://kent-orr.github.io/tabulatoR/R/render.R)) -
    [`renderTabulatoR()`](https://kent-orr.github.io/tabulatoR/reference/renderTabulatoR.md)
    and
    [`renderSpreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/renderSpreadsheet.md)
    serialize your data and configuration to JSON
2.  **Custom Shiny binding**
    ([tabulatoR.js](https://kent-orr.github.io/tabulatoR/inst/tabulatoR.js)) -
    Handles table creation, updates, and event routing
3.  **UI manipulation functions**
    ([proxy.R](https://kent-orr.github.io/tabulatoR/R/proxy.R)) - Allow
    R to invoke methods on existing tables

**Data flow:**

    R (renderTabulatoR)
      → JSON payload
      → Shiny output binding
      → Creates Tabulator instance
      → User interaction triggers events
      → Events send data back to R via Shiny.setInputValue()
      → R observes input$tableId and reacts

### Creating a Table

The main function is
[`renderTabulatoR()`](https://kent-orr.github.io/tabulatoR/reference/renderTabulatoR.md):

``` r
library(shiny)
library(tabulatoR)

ui <- fluidPage(
  tab_source(),  # Load Tabulator CSS/JS from CDN
  tabulatorOutput("myTable")
)

server <- function(input, output, session) {
  output$myTable <- renderTabulatoR(
    mtcars,
    columns = c(
      Column("Model", "model"),
      Column("MPG", "mpg", .editor = "number"),
      Column("Cylinders", "cyl", .editor = "number")
    ),
    autoColumns = FALSE,
    layout = "fitColumns"
  )
}

shinyApp(ui, server)
```

**What happens behind the scenes:**

1.  Your data.frame is converted to a list of named lists (object format
    for JavaScript)
2.  Column definitions and options are serialized to JSON
3.  The custom output binding receives this payload
4.  A new Tabulator instance is created: `new Tabulator(el, options)`
5.  The table reference is stored globally: `window[el.id] = table`

### Event Listeners

Event listeners connect JavaScript interactions back to R. tabulatoR
provides default handlers for common events, and you can override or add
custom ones.

#### Default Event Handlers

These events are automatically registered with sensible defaults:

- **`cellClick`** - Captures: field, value, row data, row index
- **`cellEdited`** - Captures: field, value, old_value, row data, row
  index
- **`validationFailed`** - Captures: field, value, validation failure
  info
- **`rowAdded`** - Captures: new row data and index
- **`rowDeleted`** - Captures: deleted row data and index

**Using default events in R:**

``` r
server <- function(input, output, session) {
  output$myTable <- renderTabulatoR(mtcars)

  # Listen to default cellEdited event
  observeEvent(input$myTable, {
    event_data <- input$myTable

    cat("Cell edited:\n")
    cat("  Field:", event_data$field, "\n")
    cat("  New value:", event_data$value, "\n")
    cat("  Old value:", event_data$old_value, "\n")
    cat("  Row index:", event_data$index, "\n")
  })
}
```

#### Custom Event Handlers

Override defaults or add new events using the `events` parameter with
the [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md)
wrapper:

``` r
output$myTable <- renderTabulatoR(
  mtcars,
  events = list(
    # Custom cellEdited handler
    cellEdited = js("
      function(cell) {
        return {
          field: cell.getField(),
          newValue: cell.getValue(),
          oldValue: cell.getOldValue(),
          rowIndex: cell.getRow().getPosition(),
          customInfo: 'Modified by user'
        };
      }
    "),

    # Row selection tracking
    rowSelectionChanged = js("
      function(data, rows) {
        return {
          selectedCount: rows.length,
          selectedIds: rows.map(r => r.getData().id)
        };
      }
    "),

    # Cell context menu
    cellContext = js("
      function(e, cell) {
        e.preventDefault();
        return {
          field: cell.getField(),
          value: cell.getValue(),
          position: { x: e.clientX, y: e.clientY }
        };
      }
    ")
  )
)
```

**How it works:**

1.  The [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md)
    function wraps your JavaScript in `<js>...</js>` tags
2.  During JSON serialization, this becomes a string
3.  The JavaScript binding detects these tags via `parseJSValue()`
4.  The string is evaluated back to an executable function: `eval(code)`
5.  When the event fires, your function processes the data
6.  The returned object is sent to R via `Shiny.setInputValue()`

**Why use [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md)
instead of `toJSON()`?**

You might wonder why tabulatoR uses this
[`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) wrapper
approach instead of R’s standard
[`jsonlite::toJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
or similar serialization methods. The reason is that **nested formulas
and custom functions don’t serialize properly** after a couple of layers
with traditional JSON serialization.

When you have deeply nested Tabulator configurations—like formatters
within column definitions, validators with custom logic, or complex
event handlers that reference other functions—standard JSON
serialization fails to preserve the executable function references. The
[`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) approach
allows these custom functions and formulas to be passed through deeply
nested structures and properly reconstructed on the JavaScript side.

While this isn’t the most ergonomic approach from an R perspective, it
gives you full access to Tabulator’s powerful JavaScript API without
limitations on nesting depth or complexity.

#### Available Tabulator Events

You can register handlers for any [Tabulator
event](http://tabulator.info/docs/5.5/events). Common ones include:

- **Data events:** `dataLoaded`, `dataChanged`, `dataFiltered`,
  `dataSorted`
- **Cell events:** `cellClick`, `cellDblClick`, `cellEdited`,
  `cellMouseEnter`
- **Row events:** `rowClick`, `rowAdded`, `rowDeleted`, `rowMoved`,
  `rowSelected`
- **Column events:** `columnMoved`, `columnResized`,
  `columnVisibilityChanged`
- **Validation:** `validationFailed`
- **Editing:** `dataEdited`, `editableCheck`

### Invoking Methods from R (UI Manipulation Functions)

Unlike traditional Shiny “proxy” objects that maintain synchronized
state between R and JavaScript, tabulatoR provides **UI manipulation
functions** that directly invoke methods on the client-side Tabulator
instance. These functions use `session$sendCustomMessage()` to send
commands to JavaScript, modifying the table without re-rendering or
maintaining a server-side copy of the table state.

#### Not Your Typical “Proxy”

If you’re coming from other popular table packages like `DT` or
`reactable`, you may be accustomed to using “proxy” objects that
decouple the rendered output from the UI state. In those
implementations, the proxy maintains a server-side representation that
stays synchronized with the client.

**tabulatoR takes a different approach:** There’s no decoupling of the
[`renderTabulatoR()`](https://kent-orr.github.io/tabulatoR/reference/renderTabulatoR.md)
output binding from the UI. Instead, we provide simple wrapper functions
that send messages directly to the existing Tabulator instance in the
browser. This means:

- No server-side state synchronization
- No proxy object to create or manage
- Direct method invocation on the client-side table
- Lighter weight and more straightforward

You simply call functions like
[`tabulatorAddRow()`](https://kent-orr.github.io/tabulatoR/reference/tabulatorAddRow.md)
or
[`tabulatorRemoveRow()`](https://kent-orr.github.io/tabulatoR/reference/tabulatorRemoveRow.md),
and they send commands to manipulate the UI table directly.

#### Adding Rows

``` r
server <- function(input, output, session) {
  output$myTable <- renderTabulatoR(mtcars)

  observeEvent(input$addRowBtn, {
    new_row <- data.frame(
      model = "New Car",
      mpg = 25,
      cyl = 4,
      stringsAsFactors = FALSE
    )

    # Add to bottom (default)
    tabulatorAddRow("myTable", new_row)

    # Or add to top
    tabulatorAddRow("myTable", new_row, add_to = "top")
  })
}
```

**Behind the scenes:**

    R: tabulatorAddRow("myTable", data, "bottom")
      → session$sendCustomMessage("tabulator-add-data", list(id = "myTable", data = data, add_to = "bottom"))
      → JS: Shiny.addCustomMessageHandler receives message
      → Finds table: document.getElementById("myTable")
      → Calls: table.addData(message.data, message.add_to)

#### Removing Rows

``` r
# Remove row at index 5
tabulatorRemoveRow("myTable", index = 5)
```

#### Replacing All Data

``` r
# Replace entire table with new data
tabulatorReplaceData("myTable", new_data_frame)
```

#### Reverting Edits

``` r
observeEvent(input$myTable, {
  edited <- input$myTable

  # Validation check
  if (edited$value < 0) {
    showNotification("Negative values not allowed!", type = "error")

    # Revert the cell to its previous value
    tabulatorRevertField(
      "myTable",
      index = edited$index,
      field = edited$field
    )
  }
})
```

#### Spreadsheet-Specific Proxies

For tables created with
[`renderSpreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/renderSpreadsheet.md):

``` r
# Replace spreadsheet data
spreadsheetSetData("mySheet", new_data)

# Clear all cells
spreadsheetClearSheet("mySheet")

# Get current spreadsheet data (triggers input$mySheet_data)
spreadsheetGetData("mySheet")

observeEvent(input$mySheet_data, {
  current_data <- input$mySheet_data
  # Process or save the data
})
```

### Direct Tabulator API Access

For advanced use cases, you can access the Tabulator instance directly
from JavaScript:

``` r
output$myTable <- renderTabulatoR(
  mtcars,
  .opts = list(
    # Any Tabulator option works here
    pagination = TRUE,
    paginationSize = 10,
    groupBy = "cyl",
    movableRows = TRUE,
    selectable = "highlight"
  )
)
```

Or use browser console JavaScript:

``` javascript
// Access the table (if table id is "myTable")
const table = window.myTable;

// Call any Tabulator method
table.deselectRow();
table.setFilter("mpg", ">", 20);
table.download("csv", "data.csv");
```

### Complete Example: Editable Table with Validation

``` r
ui <- fluidPage(
  tab_source(theme = "tabulator_bootstrap5"),
  actionButton("addRow", "Add Row"),
  actionButton("getData", "Get Current Data"),
  tabulatorOutput("editableTable"),
  verbatimTextOutput("debugInfo")
)

server <- function(input, output, session) {
  # Reactive to store current valid data
  table_data <- reactiveVal(mtcars[1:5, ])

  output$editableTable <- renderTabulatoR(
    table_data(),
    columns = c(
      Column("Model", "model"),
      Column("MPG", "mpg", .editor = "number", .validator = "min:0"),
      Column("Cylinders", "cyl", .editor = "list",
             .editorParams = list(values = c(4, 6, 8)))
    ),
    events = list(
      cellEdited = js("
        function(cell) {
          return {
            field: cell.getField(),
            value: cell.getValue(),
            old_value: cell.getOldValue(),
            index: cell.getRow().getPosition()
          };
        }
      "),
      validationFailed = js("
        function(cell, value, validators) {
          return {
            field: cell.getField(),
            invalidValue: value,
            validators: validators
          };
        }
      ")
    ),
    layout = "fitColumns"
  )

  # Handle valid edits
  observeEvent(input$editableTable, {
    edit <- input$editableTable

    # Update our reactive data store
    current <- table_data()
    current[edit$index, edit$field] <- edit$value
    table_data(current)

    output$debugInfo <- renderPrint({
      cat("Valid edit:\n")
      cat("  Row:", edit$index, "\n")
      cat("  Field:", edit$field, "\n")
      cat("  Old:", edit$old_value, "\n")
      cat("  New:", edit$value, "\n")
    })
  })

  # Handle validation failures
  observeEvent(input$editableTable_validationFailed, {
    fail <- input$editableTable_validationFailed

    showNotification(
      paste0("Invalid value for ", fail$field, ": ", fail$invalidValue),
      type = "error"
    )

    # Revert to old value
    tabulatorRevertField(
      "editableTable",
      index = fail$index,
      field = fail$field
    )
  })

  # Add new row
  observeEvent(input$addRow, {
    new_row <- data.frame(
      model = "New Car",
      mpg = 20,
      cyl = 4,
      stringsAsFactors = FALSE
    )
    tabulatorAddRow("editableTable", new_row, add_to = "bottom")
  })
}

shinyApp(ui, server)
```

This example demonstrates the full lifecycle: initial render, event
handling, validation, and UI manipulation via table methods.
