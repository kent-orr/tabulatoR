# Add row(s) to a Tabulator table

Programmatically adds one or more rows to an existing Tabulator table in
a Shiny app. This function sends a message to the JavaScript binding to
add rows to the table without re-rendering the entire widget or
modifying the underlying R data.

## Usage

``` r
tabulatorAddRow(
  outputId,
  data,
  add_to = "bottom",
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- outputId:

  The output ID of the Tabulator table (string).

- data:

  A data.frame or list representing the row(s) to add.

- add_to:

  Where to add the row(s): `"top"` or `"bottom"`. Default is `"bottom"`.

- session:

  The Shiny session object. Defaults to
  [`shiny::getDefaultReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).

## Details

The `data` parameter can be a single-row data.frame or a multi-row
data.frame. Each row will be added to the table at the specified
position.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
observeEvent(input$add_row_btn, {
  new_row <- data.frame(name = "New Person", age = 25)
  tabulatorAddRow("my_table", new_row, add_to = "top")
})
} # }
```
