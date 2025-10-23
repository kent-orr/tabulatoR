#' tag javascript for rendering in tabulatoR
#'
#' @param x a string that should be converted to a js function or symbol for use in the tabulator configs, etc.
#' @export
js <- function(x) {
  structure(
    paste0("<js>", x, "</js>"),
    class = c("tabulatoR_js", "json")  # Add "json" class so jsonlite treats as pre-formatted JSON string
  )
}
