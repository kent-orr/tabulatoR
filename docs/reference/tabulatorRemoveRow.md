# Remove row(s) from a Tabulator table

Programmatically removes row(s) from an existing Tabulator table in a
Shiny app by their index position(s). This function sends a message to
the JavaScript binding to remove rows from the table without
re-rendering the entire widget or modifying the underlying R data.

## Usage

``` r
tabulatorRemoveRow(
  outputId,
  index,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- outputId:

  The output ID of the Tabulator table (string).

- index:

  A numeric vector of row indices to remove (1-based indexing).

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Details

Row indices are 1-based (matching R's indexing convention). The
JavaScript binding will convert these to 0-based indices for Tabulator's
internal use.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$delete_row_btn, {
  tabulatorRemoveRow("my_table", index = 1)  # Remove first row
})
} # }
```
