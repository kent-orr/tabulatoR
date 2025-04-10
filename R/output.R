#' Generate Tabulator Source Links
#'
#' This function generates the necessary HTML tags to include Tabulator's CSS and JavaScript files.
#' cdn for versions and css can be found at https://app.unpkg.com/tabulator-tables
#'
#' @param version A character string specifying the version of Tabulator to use. Defaults to "6.3.1".
#' @param theme A character string specifying the theme to use. Defaults to "tabulator_bootstrap5".
#' @return A `tagList` containing the HTML tags for the Tabulator CSS and JavaScript files.
#' @examples
#' tab_source()
#' tab_source(version = "5.0", theme = "tabulator_simple")
tab_source <- function(version = "6.3.1", theme = "tabulator_bootstrap5") {
  # create a script calling requested cdns
  htmltools::tagList(
    htmltools::htmlDependency(
      name = "tabulatoR-binding",
      version = "0.0.1",
      src = c(file = system.file(package = "tabulatoR")),
      script = "tabulatoR.js"
    ),
    htmltools::tags$link(href = sprintf("https://unpkg.com/tabulator-tables@%s/dist/css/tabulator.min.css", version), rel = "stylesheet"),
    htmltools::tags$script(src = sprintf("https://unpkg.com/tabulator-tables@%s/dist/js/tabulator.min.js", version)),
    if (!is.null(theme)) {
      htmltools::tags$link(href = sprintf("https://unpkg.com/tabulator-tables@%s/dist/css/%s.min.css", version, theme), rel = "stylesheet")
    }
  )
}

#' Create a Tabulator Output Element
#'
#' This function creates a div element for rendering a Tabulator table in a Shiny application.
#'
#' @param id A character string specifying the ID of the div element.
#' @param width A character string specifying the width of the div element. Defaults to "100%".
#' @param height A character string specifying the height of the div element. Defaults to "400px".
#' @param ... Additional arguments passed to `tab_source`.
#' @return A `tagList` containing the HTML elements for the Tabulator output.
#' @examples
#' tabulatoROutput("myTable")
#' tabulatoROutput("myTable", width = "80%", height = "500px")
#' @export
tabulatoROutput <- function(id, width = "100%", height = "400px", ...) {
  htmltools::tagList(
    htmltools::singleton(htmltools::tags$head(tab_source(...))),
    htmltools::tags$div(
      id=id, width=width, height=height
    )
  )
}