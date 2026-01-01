# Set data in a Tabulator spreadsheet

Programmatically loads data into an existing Tabulator spreadsheet in a
Shiny app. This function sends a message to the JavaScript binding to
set the spreadsheet data without re-rendering the entire widget.

The function automatically converts data.frames and matrices to the
object format (list of named lists) used by Tabulator spreadsheets with
column definitions.

This function calls Tabulator's `setData()` method. For more
information, see: <https://tabulator.info/docs/6.3/data#array>

## Usage

``` r
spreadsheetSetData(outputId, data, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- outputId:

  The output ID of the Tabulator spreadsheet (string).

- data:

  A data.frame or matrix representing the spreadsheet data.

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Details

This function converts data to object format where each row is a named
list with field names matching the data.frame column names. This allows
data to be accessed by field name rather than position.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$load_data_btn, {
  new_data <- data.frame(
    A = 1:10,
    B = 11:20,
    C = 21:30
  )
  spreadsheetSetData("my_spreadsheet", new_data)
})
} # }
```
