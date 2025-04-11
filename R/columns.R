#' @title Define a Tabulator Column
#'
#' @description
#' This helper function constructs a Tabulator column definition list suitable for use
#' in `renderTabulatoR()`. It provides a concise set of the most useful column configuration
#' parameters for Shiny applications while allowing full access to Tabulator's extensive
#' API via `...` or `.opts`.
#'
#' @details
#' For the full list of column options, see the [Tabulator documentation](https://tabulator.info/docs/6.3/columns#definition).
#' JavaScript callbacks (such as `cellClick` or `formatter`) must be wrapped using `JS()`
#' from the `htmlwidgets` package to be interpreted as executable functions in the browser.
#'
#' @param title The column title to display in the table header.
#' @param field The field name in the data corresponding to this column.
#' @param visible Logical. Whether the column is visible. Default is `TRUE`.
#' @param hozAlign Horizontal text alignment for cells (`"left"`, `"center"`, `"right"`).
#' @param width A fixed column width (e.g., "150px" or "20%").
#' @param resizable Logical. Whether the user can resize this column.
#' @param editable Logical. If `TRUE`, the cells are editable.
#' @param editor Editor type (`"input"`, `"number"`, etc.) or JS function via `JS()`.
#' @param editorParams A list of parameters passed to the editor.
#' @param formatter Formatter name or JS function (use `JS()`).
#' @param formatterParams A list of parameters passed to the formatter.
#' @param cellClick JS function triggered when a cell is clicked (use `JS()`).
#' @param cellEdited JS function triggered after a cell is edited (use `JS()`).
#' @param ... Additional named Tabulator column options.
#' @param .opts A named list of column options that can be reused programmatically.
#'        Values in `...` will override matching keys in `.opts`.
#'
#' @return A named list representing a single column definition.
#' @export
Column <- function(
  title,
  field, 
  visible = TRUE, 
  hozAlign = NULL,
  width = NULL,
  resizable = NULL,
  editable = FALSE,
  editor = NULL,
  editorParams = NULL,
  formatter = NULL,
  formatterParams = NULL,
  cellClick = NULL, 
  cellEdited = NULL,
  ...,
  .opts = list()
) {
  args <- list(
    title = title,
    field = field,
    visible = visible,
    hozAlign = hozAlign,
    width = width,
    resizable = resizable,
    editable = editable,
    editor = editor,
    editorParams = editorParams,
    formatter = formatter,
    formatterParams = formatterParams,
    cellClick = cellClick,
    cellEdited = cellEdited
  )

  # Final column config: .opts first, then args, then ... (so ... wins)
  config <- c(.opts, Filter(Negate(is.null), args), list(...))
  return(config)
}



list(x = JS('() => {console.log("hey");}')) |> htmlwidgets:::toJSON2()
