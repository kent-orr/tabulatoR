# Render a Tabulator Spreadsheet in Shiny

Creates a reactive Tabulator spreadsheet widget for use in Shiny
applications. Spreadsheet mode provides an Excel-like interface with
grid-based editing, arrow key navigation, and clipboard support.

This function uses column definitions to provide real column headers
from your data.frame or matrix column names, rather than generic A, B, C
labels. Data is stored as objects (named lists) which allows for
field-based access and simpler CRUD operations.

This is a thin wrapper around Tabulator's spreadsheet mode. For complete
documentation of all available options and features, see the official
Tabulator documentation: <https://tabulator.info/docs/6.3/spreadsheet>

## Usage

``` r
renderSpreadsheet(
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
  quoted = FALSE
)
```

## Arguments

- expr:

  A reactive expression that returns a `data.frame` or `matrix`.

- editable:

  Logical. If `TRUE` (default), cells can be edited.

- columnDefinition:

  A list defining default properties for all columns. For example,
  `list(editor = "input", validator = "numeric")`. See
  <https://tabulator.info/docs/6.3/columns> for all column options.

- selectableRange:

  Logical. If `TRUE`, enables range selection with mouse/keyboard. See
  <https://tabulator.info/docs/6.3/select#range>

- clipboardPasteAction:

  Character. Action to take when pasting data. Options: "replace"
  (default) or "update". See <https://tabulator.info/docs/6.3/clipboard>

- events:

  A named list of JS events that should be sent back to Shiny as input
  values. See <https://tabulator.info/docs/6.3/events> for all available
  events.

- options:

  A named list of additional Tabulator options to customize the
  spreadsheet. All Tabulator configuration options are supported. See
  <https://tabulator.info/docs/6.3/options>

- ...:

  Additional named elements to include in the payload passed to the
  front-end.

- .opts:

  A named list of additional payload entries, useful for programmatic
  inclusion. Elements in `...` will override matching keys in `.opts`.

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Logical. Is `expr` already quoted? If not, it will be quoted.

## Value

A function that returns a list to be serialized and passed to the
Tabulator output binding.

## Details

Spreadsheet mode differs from standard table mode in several ways:

- Column headers display actual data.frame/matrix column names

- Data is stored as objects with field names for easier access

- **Double-click** a cell to enter edit mode (or press Enter)

- Use **arrow keys** to navigate between cells

- Press **Tab** to move to the next cell

- Built-in support for copy/paste operations (Ctrl+C / Ctrl+V)

- Cannot use features like pagination, grouping, or tree structures

The `editTriggerEvent` is set to "dblclick" by default for smoother
navigation. This allows you to click cells to select them and use arrow
keys to navigate without accidentally entering edit mode.

JavaScript callbacks (such as event handlers) must be wrapped using
[`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) from this
package to be interpreted as executable functions in the browser.

## Examples

``` r
if (interactive()) {
  library(shiny)

  ui <- fluidPage(
    spreadsheetOutput("sheet")
  )

  server <- function(input, output, session) {
    output$sheet <- renderSpreadsheet(
      head(mtcars),
      editable = TRUE,
      selectableRange = TRUE
    )
  }

  shinyApp(ui, server)
}
```
