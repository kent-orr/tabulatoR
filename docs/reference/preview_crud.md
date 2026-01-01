# Preview a Tabulator table with basic CRUD

Launches a Shiny application demonstrating create, read, update and
delete operations on a Tabulator table. Rows can be edited directly in
the table, and users can add rows via a button. A `verbatimTextOutput`
displays the Shiny input events emitted by the table when rows are
edited.

## Usage

``` r
preview_crud()
```

## Value

A `shiny.appobj` object.

## Details

This example demonstrates the recommended pattern for handling Tabulator
events: use a single `observeEvent(input$table, {...})` and branch based
on the `action` field.

## Examples

``` r
if (interactive()) {
    preview_crud()
}
```
