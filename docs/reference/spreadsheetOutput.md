# Output element for a Tabulator spreadsheet

Creates an output element in the Shiny UI to display a Tabulator
spreadsheet. This should be paired with
[`renderSpreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/renderSpreadsheet.md)
in the server function.

## Usage

``` r
spreadsheetOutput(outputId, width = "100%", height = "400px", ...)
```

## Arguments

- outputId:

  The output variable to read the spreadsheet from.

- width:

  The width of the spreadsheet container (default: "100%").

- height:

  The height of the spreadsheet container (default: "400px").

- ...:

  Additional arguments passed to
  [`tab_source()`](https://kent-orr.github.io/tabulatoR/reference/tab_source.md)
  for customizing Tabulator version and theme.

## Value

An HTML widget container for the spreadsheet.

## Examples

``` r
if (interactive()) {
  library(shiny)

  ui <- fluidPage(
    spreadsheetOutput("my_spreadsheet", height = "600px")
  )

  server <- function(input, output, session) {
    output$my_spreadsheet <- renderSpreadsheet(
      data.frame(
        A = 1:10,
        B = 11:20,
        C = 21:30
      )
    )
  }

  shinyApp(ui, server)
}
```
