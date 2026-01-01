# Create a Tabulator Output Element

This function creates a div element for rendering a Tabulator table in a
Shiny application.

## Usage

``` r
tabulatoROutput(id, width = "100%", height = "400px", ...)
```

## Arguments

- id:

  A character string specifying the ID of the div element.

- width:

  A character string specifying the width of the div element. Defaults
  to "100%".

- height:

  A character string specifying the height of the div element. Defaults
  to "400px".

- ...:

  Additional arguments passed to `tab_source`.

## Value

A `tagList` containing the HTML elements for the Tabulator output.

## Examples

``` r
tabulatoROutput("myTable")
#> <div id="myTable" class="tabulator-output" width="100%" height="400px"></div>
tabulatoROutput("myTable", width = "80%", height = "500px")
#> <div id="myTable" class="tabulator-output" width="80%" height="500px"></div>
```
