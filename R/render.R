#' @title Render a Tabulator Table in Shiny
#'
#' @description
#' Creates a reactive Tabulator table widget for use in Shiny applications.
#' Returns a function that outputs a JSON-serializable payload consumed by the
#' custom tabulatoR JavaScript output binding.
#'
#' @param expr A reactive expression that returns a `data.frame`.
#' @param columns An array (i.e., `c(...)`) of column definitions for Tabulator. Each element must
#'                be a list representing a column config (e.g., `list(field = "name", editable = TRUE)`).
#'                This ensures JSON serializes correctly as an array, not a named list. See
#'                <https://tabulator.info/docs/6.3/columns> for full details.
#' @param layout a string defining the overall table layout. https://tabulator.info/docs/6.3/layout#layout
#' @param autoColumns Logical. If `TRUE`, columns will be auto-generated from the data.
#'                Set to `FALSE` if you're supplying a custom column definitions.
#' @param editable Logical. If `TRUE`, the cells can be editable. Pair with editor=<editgor_type> when not using autocolumns. 
#' @param options A named list of additional Tabulator options (e.g. pagination, layout).
#' @param events A named list of JS events that should be sent back to Shiny as input values.
#' @param ... Additional named elements to include in the payload passed to the front-end.
#' @param .opts A named list of additional payload entries, useful for programmatic inclusion.
#'              Elements in `...` will override matching keys in `.opts`.
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Logical. Is `expr` already quoted? If not, it will be quoted.
#'
#' @details
#' JavaScript callbacks (such as `cellClick` or `formatter`) must be wrapped using `JS()`
#' from the `htmlwidgets` package to be interpreted as executable functions in the browser.
#' 
#' @return A function that returns a list to be serialized and passed to the Tabulator output binding.
#' @export
renderTabulatoR <- function(
  expr,
  columns = c(),
  layout='fitColumns',
  autoColumns = TRUE,
  editable=TRUE,
  events = NULL,
  ...,
  .opts = list(),
  env = parent.frame(),
  quoted = FALSE) {
    
  func <- shiny::exprToFunction(expr, env, quoted)
  
  function() {
    data <- func()
    if (!is.data.frame(data)) stop("Reactive must return a data.frame")
    
    # Convert to list of rows
    data_list <- unname(split(data, seq(nrow(data))))
    
    config <- list(
      data = data_list
    )
    
    # Use provided columns if any, otherwise handle autoColumns logic
    if (length(columns) > 0) {
      config$columns <- columns
    } else if (autoColumns) {
      # Auto-generate columns based on the editable flag
      config$columns <- unname(lapply(names(data), function(col) {
        list(title = col, field = col, editor = if(editable) TRUE else NULL)
      }))
    } else {
      config$autoColumns <- TRUE
    }
    
    config <- c(config, layout=layout, .opts, list(...))
    
    payload <- c(
      list(
        options = config,
        events = events
      )
    )

    htmlwidgets:::toJSON2(payload, auto_unbox = TRUE)

  }
} 
  
#' @title Replace the data in a Tabulator table via proxy
#'
#' @description
#' Replaces the current table data in the browser with a new data.frame.
#' This does not trigger a full re-render of the table.
#'
#' @param id The ID of the Tabulator table.
#' @param proxy A `tabulatorProxy` object created with `tabulatorProxy()`.
#' @param data A `data.frame` to send to the client-side Tabulator table.
#' @param session The Shiny session object.
#'
#' @export
tabulatorReplaceData <- function(id, data, session = getDefaultReactiveDomain()) {
  if (!is.data.frame(data)) stop("Data must be a data.frame")

  data_list <- unname(split(data, seq(nrow(data))))
  
  session$sendCustomMessage(
    type = "tabulator-replace-data",
    message = list(
      id = id,
      data = data_list
    )
  )
}

#' @title Append rows to a Tabulator table via proxy
#'
#' @description
#' Adds new rows to the top or bottom of an existing Tabulator table.
#' 
#' @inheritParams tabulatorReplaceData
#' @param add_to Whether to add rows to the "top" or "bottom" of the table.
#'
#' @export
tabulatorAddData <- function(id, data, add_to = c("top", "bottom"), session = getDefaultReactiveDomain()) {
  if (!is.data.frame(data)) stop("Data must be a data.frame")
  
  add_to <- match.arg(add_to)
  data_list <- unname(split(data, seq(nrow(data))))

  session$sendCustomMessage(
    type = "tabulator-add-data",
    message = list(
      id = id,
      data = data_list,
      addToTop = add_to == "top"
    )
  )
}

#' @title Remove a row from a Tabulator table by index
#'
#' @description
#' Removes a row from the table using Tabulator's internal row index system.
#' This is not the R row number — it is the index returned from a Tabulator event
#' (e.g., `input$my_table$rowClick$index`).
#'
#' @inheritParams tabulatorReplaceData
#' @param index An integer index corresponding to the Tabulator row index.
#'   Use the `index` value from an event payload (e.g., `input$my_table$cellClick$index`).
#'
#' @export
tabulatorRemoveRow <- function(id, index, session = getDefaultReactiveDomain()) {
  
  session$sendCustomMessage(
    type = "tabulator-remove-row",
    message = list(
      id = id,
      index = index
    )
  )
}  

#' @title Restore the old value in a cell after editing
#'
#' @description
#' Restores the old value in a cell after editing, useful for preserving the original if validation fails.
#' 
#' @inheritParams tabulatorRemoveRow
#' 
tabulatorRestoreOldValue <- function(id, index, field, session = getDefaultReactiveDomain()) {
    session$sendCustomMessage(
        type = "tabulator-restore-old-value",
        message = list(
            id = id,
            index = index,
            field = field
        )
    )
}