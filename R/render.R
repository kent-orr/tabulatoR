#' Flatten nested column lists into a flat list of column objects
#'
#' @param columns A list or vector that may contain nested column definitions
#' @return A flat list of column objects
#' @keywords internal
flatten_columns <- function(columns) {
        if (length(columns) == 0) {
                return(structure(list(), names = NULL))
        }
        
        result <- list()
        
        for (i in seq_along(columns)) {
                item <- columns[[i]]
                
                # Unwrap single-element lists that contain the actual column definition
                # This handles Column() function output: list(list(title=..., field=...))
                while (is.list(item) && length(item) == 1 && is.list(item[[1]])) {
                        item <- item[[1]]
                }
                
                result[[length(result) + 1]] <- item
        }
        
        # Return unnamed list to match c() behavior
        structure(result, names = NULL)
}



#' @title Render a Tabulator Table in Shiny
#'
#' @description
#' Creates a reactive Tabulator table widget for use in Shiny applications.
#' Returns a function that outputs a JSON-serializable payload consumed by the
#' custom tabulatoR JavaScript output binding.
#'
#' This is a thin wrapper around Tabulator. For complete documentation of all available
#' options and features, see the official Tabulator documentation:
#' \url{https://tabulator.info/docs/6.3}
#'
#' @param expr A reactive expression that returns a `data.frame`.
#' @param columns An array (`c(...)`) or list of column definitions for Tabulator. Each element must
#'                be a list representing a column config (e.g., `list(field = "name", editable = TRUE)`).
#'                Any lists are coerced into an unnamed vector to ensure JSON serializes as an array.
#'                See \url{https://tabulator.info/docs/6.3/columns} for all column options.
#' @param layout A string defining the overall table layout.
#'               See \url{https://tabulator.info/docs/6.3/layout}
#' @param autoColumns Logical. If `TRUE`, columns will be auto-generated from the data.
#'                    Set to `FALSE` if you're supplying custom column definitions.
#' @param editable Logical. If `TRUE`, the cells can be editable. Pair with `editor` parameter in columns.
#' @param options A named list of additional Tabulator options (e.g. pagination, sorting, filtering).
#'                All Tabulator configuration options are supported.
#'                See \url{https://tabulator.info/docs/6.3/options}
#' @param events A named list of JS events that should be sent back to Shiny as input values.
#'               See \url{https://tabulator.info/docs/6.3/events} for all available events.
#' @param ... Additional named elements to include in the payload passed to the front-end.
#' @param .opts A named list of additional payload entries, useful for programmatic inclusion.
#'              Elements in `...` will override matching keys in `.opts`.
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Logical. Is `expr` already quoted? If not, it will be quoted.
#'
#' @details
#' JavaScript callbacks (such as `cellClick` or `formatter`) must be wrapped using `js()`
#' from this package to be interpreted as executable functions in the browser.
#'
#' For spreadsheet functionality, see [renderSpreadsheet()].
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

        # Convert to list of rows (as proper lists, not data.frames)
        data_list <- lapply(seq_len(nrow(data)), function(i) {
            as.list(data[i, ])
        })
        
        config <- list(
            data = data_list
        )
        
        # Use provided columns if any, otherwise handle autoColumns logic
        if (length(columns) > 0) {
                # Flatten nested lists - keep unwrapping until we have a flat list of column objects
                while (any(vapply(columns, function(x) length(x) == 1 && is.list(x[[1]]), logical(1)))) {
                        columns <- unlist(columns, recursive = FALSE)
                }
                config$columns <- unname(columns)
        } else if (autoColumns) {
                # Auto-generate columns based on the editable flag
                config$columns <- unname(lapply(names(data), function(col) {
                        # Use NA (not NULL) for null in JSON when editable=FALSE
                        # jsonlite converts NULL to {} and NA to null
                        list(title = col, field = col, editor = if(editable) TRUE else NA)
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

        jsonlite::toJSON(payload, auto_unbox = TRUE)

    }
} 
    