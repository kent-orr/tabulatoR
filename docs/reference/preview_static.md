# Preview a static Tabulator table

Launches a minimal Shiny application showing a non-editable Tabulator
table. This can be used to quickly preview the package output or within
automated tests.

## Usage

``` r
preview_static()
```

## Value

A `shiny.appobj` object.

## Examples

``` r
if (interactive()) {
    preview_static()
}
```
