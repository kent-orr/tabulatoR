# Clear all data from a Tabulator spreadsheet

Programmatically clears all data from an existing Tabulator spreadsheet
in a Shiny app. This function sends a message to the JavaScript binding
to clear the spreadsheet without re-rendering the entire widget.

This function calls Tabulator's `clearSheet()` method. For more
information, see: <https://tabulator.info/docs/6.3/spreadsheet#clear>

## Usage

``` r
spreadsheetClearSheet(outputId, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- outputId:

  The output ID of the Tabulator spreadsheet (string).

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Details

This calls Tabulator's `clearSheet()` method, which removes all data but
preserves the spreadsheet configuration and structure.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$clear_btn, {
  spreadsheetClearSheet("my_spreadsheet")
})
} # }
```
