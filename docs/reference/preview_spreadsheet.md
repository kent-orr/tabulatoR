# Preview a Tabulator spreadsheet

Launches a Shiny application demonstrating spreadsheet functionality
with Excel-like grid editing, arrow key navigation, and data
manipulation via proxy functions. Users can edit cells, load new data,
and clear the spreadsheet.

## Usage

``` r
preview_spreadsheet()
```

## Value

A `shiny.appobj` object.

## Details

This example demonstrates:

- Spreadsheet mode with editable cells

- Arrow key navigation and Enter to edit

- Proxy functions:
  [`spreadsheetSetData()`](https://kent-orr.github.io/tabulatoR/reference/spreadsheetSetData.md)
  and
  [`spreadsheetClearSheet()`](https://kent-orr.github.io/tabulatoR/reference/spreadsheetClearSheet.md)

- Range selection for copy/paste operations

- Event handling for cell edits

## Examples

``` r
if (interactive()) {
    preview_spreadsheet()
}
```
