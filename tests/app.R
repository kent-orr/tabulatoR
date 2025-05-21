library(shiny)
devtools::load_all()  # Use this if you're testing a local package

ui <- fluidPage(
  tags$h2("TabulatoR Debug App"),

  actionButton("inc", "Increment First MPG"),
  actionButton("rem", "Remove Row"),
  tabulatoROutput("main_table"),
  shiny::tags$p(),
  verbatimTextOutput("debug_output")
)

server <- function(input, output, session) {
  # Reactive data that changes when the button is clicked
  rdata <- reactive({
    df <- head(mtcars)
    df$mpg[1] <- df$mpg[1] + input$inc
    if (input$rem > 0) {
      df = df[-as.integer(input$rem),]
    }
    df
  })

  # Send data to Tabulator
  output$main_table <- renderTabulatoR({
    print('re-rendering the table')
    rdata()
  }, editable=TRUE
  , columns = c(
    Column('Car', 'car')
    , Column('MPG', 'mpg', editable=TRUE, editor = 'input')
    , Column('Cyl', 'cyl')
    , Column('Disp', 'disp')
    , Column('HP', 'hp')
    , ActionColumn('Delete', 'delete')
  )
)


  # Show data in console
  output$debug_output <- renderPrint({
    list(
      data = rdata(),
      inputs =  str(input$main_table)
    )
  })
}

shinyApp(ui, server)

