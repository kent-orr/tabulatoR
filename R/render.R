#' @title Render a Tabulator Table in Shiny
#'
#' @description
#' Creates a reactive Tabulator table widget for use in Shiny applications.
#' Returns a function that outputs a JSON-serializable payload consumed by the
#' custom tabulatoR JavaScript output binding.
#'
#' @param expr A reactive expression that returns a `data.frame`.
#' @param autoColumns Logical. If `TRUE`, columns will be auto-generated from the data.
#'                Set to `FALSE` if you're supplying a custom column definition.
#' @param editable Logical. If `TRUE`, the table cells will be editable.
#' @param columns An array (i.e., `c(...)`) of column definitions for Tabulator. Each element must
#'                be a list representing a column config (e.g., `list(field = "name", editable = TRUE)`).
#'                This ensures JSON serializes correctly as an array, not a named list. See
#'                <https://tabulator.info/docs/6.3/columns> for full details.
#' @param options A named list of additional Tabulator options (e.g. pagination, layout).
#' @param events A named list of JS events that should be sent back to Shiny as input values.
#' @param ... Additional named elements to include in the payload passed to the front-end.
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Logical. Is `expr` already quoted? If not, it will be quoted.
#'
#' @return A function that returns a list to be serialized and passed to the Tabulator output binding.
#' @export
renderTabulatoR <- function(expr,
    autoColumns = TRUE,
    editable = TRUE,
    columns = c(),
    options = list(),
    events = list(),
    ...,
    env = parent.frame(),
    quoted = FALSE) {
        func <- shiny::exprToFunction(expr, env, quoted)
        
        function() {
            data <- func()
            if (!is.data.frame(data)) stop("Reactive must return a data.frame")
            
            # Convert to list of rows
            data_list <- unname(split(data, seq(nrow(data))))
            
            config <- list(
                data = data_list,
                editable = editable
            )
            
            if (length(columns)) {
                config$columns <- columns
            } else if (autoColumns) {
                config$columns <- unname(lapply(names(data), function(col) {
                    list(title = col, field = col)
                }))
            }
            
            config <- c(config, options)
            
            payload <- c(
                list(
                    options = config,
                    events = events
                ),
                list(...)
            )
            
            payload
        }
    }
    
#' @title Create a proxy object for an existing Tabulator table
#'
#' @description
#' Use this function to send commands to an already-rendered Tabulator table
#' in the browser, without triggering a full redraw. Useful for replacing data,
#' selecting rows, or other JS-driven operations.
#'
#' @param id The output ID of the Tabulator table.
#' @param session The Shiny session (defaults to current session).
#'
#' @return A proxy object to be used with other tabulatoR proxy functions.
#' @export
tabulatorProxy <- function(id, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) stop("tabulatorProxy must be called from within a Shiny session")
  
  structure(
    list(id = id, session = session),
    class = "tabulatorProxy"
  )
}

#' @title Replace data in an existing Tabulator table via proxy
#' @param proxy A tabulatorProxy object created by `tabulatorProxy()`.
#' @param data A data.frame to send to the client.
#' @export
tabulatorReplaceData <- function(proxy, data) {
  if (!inherits(proxy, "tabulatorProxy")) stop("Must pass a tabulatorProxy")
  
  data_list <- unname(split(data, seq(nrow(data))))
  
  proxy$session$sendCustomMessage(
    type = "tabulator-replace-data",
    message = list(
      id = proxy$id,
      data = data_list
    )
  )
}

tabulatorAddData <- function(proxy, data) {
  
}

