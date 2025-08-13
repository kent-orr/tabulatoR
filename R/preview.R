#' Preview a static Tabulator table
#'
#' Launches a minimal Shiny application showing a non-editable Tabulator table.
#' This can be used to quickly preview the package output or within automated tests.
#'
#' @return A `shiny.appobj` object.
#' @examples
#' if (interactive()) {
#'     preview_static()
#' }
#' @export
preview_static <- function() {
    ui <- shiny::fluidPage(
        tabulatoROutput("static_table")
    )

    server <- function(input, output, session) {
        output$static_table <- renderTabulatoR(head(mtcars), editable = FALSE)
    }

    shiny::shinyApp(ui, server)
}

