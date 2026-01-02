# tabulatoR

**tabulatoR** wraps [Tabulator JS](https://tabulator.info/) for Shiny with minimal abstraction.

- **Low barrier**: CRUD operations work out-of-the-box in R
- **High ceiling**: Direct access to Tabulator JS API for custom behavior
- **For users who want R convenience + JS power when needed**

Whether you need a simple sortable table or complex custom interactions, tabulatoR gives you the flexibility to start simple and go deep when you need to.

## Key Features

- **Column-first design** – Define columns with their own behavior, formatting, and interactivity
- **Direct JavaScript integration** – Use custom JS inline for limitless customization
- **Shiny-ready** – Built from the ground up for reactive, event-driven apps
- **Lightweight & flexible** – Only load what you need, without heavy dependencies

## Quick Start

```r
# remotes::install_github("kent-orr/tabulatoR")
library(shiny); library(tabulatoR)

shinyApp(
  ui = fluidPage(tabulatoROutput("table"), verbatimTextOutput("edits")),
  server = function(input, output) {
    output$table <- renderTabulatoR(head(cars), editable = TRUE)
    output$edits <- renderPrint(str(input$table))
  }
)
```
