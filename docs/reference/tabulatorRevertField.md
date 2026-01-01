# Revert a cell to its previous value

Programmatically reverts a cell in a Tabulator table back to its
previous value. This is useful when validation fails or when you want to
undo a user's edit.

## Usage

``` r
tabulatorRevertField(
  outputId,
  index,
  field,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- outputId:

  The output ID of the Tabulator table (string).

- index:

  The row index (1-based) of the cell to revert.

- field:

  The field name (column name) of the cell to revert.

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Details

This function calls Tabulator's `cell.restoreOldValue()` method, which
reverts the cell to the value it had before the most recent edit.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$my_table, {
  event <- input$my_table

  if (event$action == "cellEdited" && event$value < 0) {
    # Revert negative values
    tabulatorRevertField("my_table", event$index, event$field)
  }
})
} # }
```
