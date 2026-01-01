# tabulatoR

**tabulatoR** is an R package that brings the powerful [Tabulator
JavaScript library](https://tabulator.info/) to Shiny applications.  
It’s a lightweight, extensible wrapper designed for **interactive,
highly customizable data tables in R**.

## Key Features

- **Column-first design** – Define columns with their own behavior,
  formatting, and interactivity.
- **Direct JavaScript integration** – Use custom JS inline for limitless
  customization.
- **Shiny-ready** – Built from the ground up for reactive, event-driven
  apps.
- **Lightweight & flexible** – Only load what you need, without heavy
  dependencies.

## Quick Start

``` r
# Install from GitHub
# remotes::install_github("yourusername/tabulatoR")

library(shiny)
library(tabulatoR)

ui <- fluidPage(
  tabulatorOutput("my_table")
)

server <- function(input, output, session) {
  output$my_table <- renderTabulator({
    tabulator(iris, columns = list(
      list(title = "Sepal.Length", field = "Sepal.Length", sorter = "number"),
      list(title = "Species", field = "Species", sorter = "string")
    ))
  })
}

shinyApp(ui, server)
```
