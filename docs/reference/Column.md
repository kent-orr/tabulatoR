# Define a Tabulator Column

This helper function constructs a Tabulator column definition list
suitable for use in
[`renderTabulatoR()`](https://kent-orr.github.io/tabulatoR/reference/renderTabulatoR.md).
It provides a concise set of the most useful column configuration
parameters for Shiny applications while allowing full access to
Tabulator's extensive API via `...` or `.opts`.

## Usage

``` r
Column(
  title,
  field,
  visible = TRUE,
  hozAlign = NULL,
  width = NULL,
  resizable = NULL,
  editable = FALSE,
  editor = NULL,
  editorParams = NULL,
  formatter = NULL,
  formatterParams = NULL,
  cellClick = NULL,
  cellEdited = NULL,
  ...,
  .opts = list()
)
```

## Arguments

- title:

  The column title to display in the table header.

- field:

  The field name in the data corresponding to this column.

- visible:

  Logical. Whether the column is visible. Default is `TRUE`.

- hozAlign:

  Horizontal text alignment for cells (`"left"`, `"center"`, `"right"`).

- width:

  A fixed column width (e.g., "150px" or "20%").

- resizable:

  Logical. Whether the user can resize this column.

- editable:

  Logical. If `TRUE`, the cells are editable. When set to `TRUE` and
  `editor` is `NULL`, Tabulator guesses the editor (`editor = TRUE`).

- editor:

  Editor type (`"input"`, `"number"`, etc.) or JS function via
  [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md).
  Supplying this parameter implicitly enables editing.

- editorParams:

  A list of parameters passed to the editor.

- formatter:

  Formatter name or JS function (use
  [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md)).

- formatterParams:

  A list of parameters passed to the formatter.

- cellClick:

  JS function triggered when a cell is clicked (use
  [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md)).

- cellEdited:

  JS function triggered after a cell is edited (use
  [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md)).

- ...:

  Additional named Tabulator column options.

- .opts:

  A named list of column options that can be reused programmatically.
  Values in `...` will override matching keys in `.opts`.

## Value

A named list representing a single column definition.

## Details

For the full list of column options, see the [Tabulator
documentation](https://tabulator.info/docs/6.3/columns#definition).
JavaScript callbacks (such as `cellClick` or `formatter`) must be
wrapped using
[`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) from this
package to be interpreted as executable functions in the browser.
Supplying `editor` implicitly enables editing. If `editable = TRUE` and
no `editor` is provided, Tabulator attempts to guess the editor
(`editor = TRUE`).
