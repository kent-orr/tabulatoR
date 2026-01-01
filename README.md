# tabulatoR

tabulatoR makes it easy to add fast, editable tables to Shiny apps with minimal setup.

## Who this is for

This package can accommodate R and Shiny users who want:

- An editable table
- Reasonable defaults
- No JavaScript required

But still has direct access to the powerful Tabulator API for deep customization and functionality like callbacks, server-side messages, and custom formatters when you need it.

## Why tabulatoR instead of DT or reactable

Use tabulatoR when you need:

- In-place cell editing
- Row additions and deletions
- Large tables that stay responsive
- Some serious customization of display, editing, and callback functions


## Quick Start

```r
# remotes::install_github("kent-orr/tabulatoR")
library(shiny)
library(tabulatoR)

ui <- fluidPage(
  tabulatoROutput("table"),
  verbatimTextOutput("edits")
)

server <- function(input, output, session) {
    output$table <- renderTabulatoR(head(cars), editable=TRUE)
    output$edits <- renderPrint(str(input$table))
}

shinyApp(ui, server)
```

**This creates an editable table.**
Click a cell to edit it. Changes are available on the server through standard Shiny inputs.

## What you get out of the box

- Editable cells
- Sorting and filtering
- Large table performance
- Works inside standard Shiny reactivity

## Low barrier, high ceiling

Start simple with defaults. When you need more, tabulatoR gives you direct access to the full Tabulator API—no fighting the wrapper. Pass custom column definitions, add JavaScript formatters, or hook into any Tabulator feature without leaving R.
