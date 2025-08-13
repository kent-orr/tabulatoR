library(shiny)
devtools::load_all()

ui <- fluidPage(
    tabulatoROutput("tbl")
)

server <- function(input, output, session) {
    output$tbl <- renderTabulatoR(
        data.frame(a = 1),
        events = list(
            cellClick = js("\n                function(e, cell){\n                    return { action: 'cellClick', nested: [[cell.getValue()]] };\n                }\n            ")
        )
    )
}

shinyApp(ui, server)
