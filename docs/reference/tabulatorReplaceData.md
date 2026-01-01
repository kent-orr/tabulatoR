# Replace all data in a Tabulator table

Programmatically replaces all data in an existing Tabulator table in a
Shiny app. This is more efficient than re-rendering the entire widget
when you want to update the table contents while preserving the table
configuration and state.

## Usage

``` r
tabulatorReplaceData(
  outputId,
  data,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- outputId:

  The output ID of the Tabulator table (string).

- data:

  A data.frame representing the new table data.

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$refresh_btn, {
  new_data <- fetch_updated_data()
  tabulatorReplaceData("my_table", new_data)
})
} # }
```
