library(shiny)
devtools::load_all()  # Use this if you're testing a local package

ui <- fluidPage(
  tags$h2("TabulatoR Debug App"),

  actionButton("inc", "Increment First MPG"),
  tabulatoROutput("main_table"),
  verbatimTextOutput("debug_output")
)

server <- function(input, output, session) {
  # Reactive data that changes when the button is clicked
  rdata <- reactive({
    df <- head(mtcars)
    df$mpg[1] <- df$mpg[1] + input$inc
    df
  })

  # Send data to Tabulator
  output$main_table <- renderTabulatoR({
    rdata()
  })

  # Show data in console
  output$debug_output <- renderPrint({
    list(
      input_cell_edited = input$main_table_cellEdited,
      data = rdata()
    )
  })
}

shinyApp(ui, server)

