# Render a Tabulator Table in Shiny

Creates a reactive Tabulator table widget for use in Shiny applications.
Returns a function that outputs a JSON-serializable payload consumed by
the custom tabulatoR JavaScript output binding.

This is a thin wrapper around Tabulator. For complete documentation of
all available options and features, see the official Tabulator
documentation: <https://tabulator.info/docs/6.3>

## Usage

``` r
renderTabulatoR(
  expr,
  columns = c(),
  layout = "fitColumns",
  autoColumns = TRUE,
  editable = TRUE,
  events = NULL,
  ...,
  .opts = list(),
  env = parent.frame(),
  quoted = FALSE
)
```

## Arguments

- expr:

  A reactive expression that returns a `data.frame`.

- columns:

  An array (`c(...)`) or list of column definitions for Tabulator. Each
  element must be a list representing a column config (e.g.,
  `list(field = "name", editable = TRUE)`). Any lists are coerced into
  an unnamed vector to ensure JSON serializes as an array. See
  <https://tabulator.info/docs/6.3/columns> for all column options.

- layout:

  A string defining the overall table layout. See
  <https://tabulator.info/docs/6.3/layout>

- autoColumns:

  Logical. If `TRUE`, columns will be auto-generated from the data. Set
  to `FALSE` if you're supplying custom column definitions.

- editable:

  Logical. If `TRUE`, the cells can be editable. Pair with `editor`
  parameter in columns.

- events:

  A named list of JS events that should be sent back to Shiny as input
  values. See <https://tabulator.info/docs/6.3/events> for all available
  events.

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

- options:

  A named list of additional Tabulator options (e.g. pagination,
  sorting, filtering). All Tabulator configuration options are
  supported. See <https://tabulator.info/docs/6.3/options>

## Value

A function that returns a list to be serialized and passed to the
Tabulator output binding.

## Details

JavaScript callbacks (such as `cellClick` or `formatter`) must be
wrapped using
[`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) from this
package to be interpreted as executable functions in the browser.

For spreadsheet functionality, see
[`renderSpreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/renderSpreadsheet.md).
