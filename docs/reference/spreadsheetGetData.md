# Request current data from a Tabulator spreadsheet

Programmatically requests the current data from a Tabulator spreadsheet.
This function sends a message to the JavaScript binding to retrieve the
spreadsheet data, which will be sent back to Shiny as an input value.

This function calls Tabulator's `getData()` method. For more
information, see: <https://tabulator.info/docs/6.3/data#retrieve>

## Usage

``` r
spreadsheetGetData(outputId, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- outputId:

  The output ID of the Tabulator spreadsheet (string).

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Details

After calling this function, the spreadsheet data will be available in
`input$<outputId>_data` as a list of named lists (object format), where
each list element contains the field names and values for one row.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$get_data_btn, {
  spreadsheetGetData("my_spreadsheet")
})

# Access the data in a reactive context
observe({
  data <- input$my_spreadsheet_data
  if (!is.null(data)) {
    # Convert to data.frame if needed
    df <- do.call(rbind.data.frame, data)
    print(df)
  }
})
} # }
```
