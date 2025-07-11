#' tag javascript for rendering in tabulatoR
#' 
#' @param x a string that should be converted to a js function or symbol for use int he tabulator configs, etc.
#' @export
#' @export
js <- function(x) {
  structure(
    paste0("<js>", x, "</js>"),
    class = "tabulatoR_js"
  )
}
