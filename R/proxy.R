#' Add data to a Tabulator table
#'
#' @description
#' Programmatically adds one or more rows to an existing Tabulator table in a Shiny app.
#' This function sends a message to the JavaScript binding to add data to the table
#' without re-rendering the entire widget.
#'
#' @param outputId The output ID of the Tabulator table (string).
#' @param data A data.frame or list representing the row(s) to add.
#' @param add_to Where to add the data: `"top"` or `"bottom"`. Default is `"bottom"`.
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @details
#' The `data` parameter can be a single-row data.frame or a multi-row data.frame.
#' Each row will be added to the table at the specified position.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$add_row_btn, {
#'   new_row <- data.frame(name = "New Person", age = 25)
#'   tabulatorAddData("my_table", new_row, add_to = "top")
#' })
#' }
#'
#' @export
tabulatorAddData <- function(outputId, data, add_to = "bottom", session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("tabulatorAddData must be called from within a Shiny server function")
  }

  # Convert data.frame to list of rows
  if (is.data.frame(data)) {
    data_list <- unname(split(data, seq(nrow(data))))
  } else if (is.list(data)) {
    data_list <- list(data)
  } else {
    stop("data must be a data.frame or list")
  }

  session$sendCustomMessage("tabulator-add-data", list(
    id = session$ns(outputId),
    data = data_list,
    add_to = add_to
  ))
}


#' Remove data from a Tabulator table
#'
#' @description
#' Programmatically removes row(s) from an existing Tabulator table in a Shiny app
#' by their index position(s). This function sends a message to the JavaScript binding
#' to remove data from the table without re-rendering the entire widget.
#'
#' @param outputId The output ID of the Tabulator table (string).
#' @param index A numeric vector of row indices to remove (1-based indexing).
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @details
#' Row indices are 1-based (matching R's indexing convention). The JavaScript binding
#' will convert these to 0-based indices for Tabulator's internal use.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$delete_row_btn, {
#'   tabulatorRemoveData("my_table", index = 1)  # Remove first row
#' })
#' }
#'
#' @export
tabulatorRemoveData <- function(outputId, index, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("tabulatorRemoveData must be called from within a Shiny server function")
  }

  session$sendCustomMessage("tabulator-remove-data", list(
    id = session$ns(outputId),
    index = index
  ))
}


#' Replace all data in a Tabulator table
#'
#' @description
#' Programmatically replaces all data in an existing Tabulator table in a Shiny app.
#' This is more efficient than re-rendering the entire widget when you want to update
#' the table contents while preserving the table configuration and state.
#'
#' @param outputId The output ID of the Tabulator table (string).
#' @param data A data.frame representing the new table data.
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$refresh_btn, {
#'   new_data <- fetch_updated_data()
#'   tabulatorReplaceData("my_table", new_data)
#' })
#' }
#'
#' @export
tabulatorReplaceData <- function(outputId, data, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("tabulatorReplaceData must be called from within a Shiny server function")
  }

  if (!is.data.frame(data)) {
    stop("data must be a data.frame")
  }

  # Convert to list of rows
  data_list <- unname(split(data, seq(nrow(data))))

  session$sendCustomMessage("tabulator-replace-data", list(
    id = session$ns(outputId),
    data = data_list
  ))
}


#' Revert a cell to its previous value
#'
#' @description
#' Programmatically reverts a cell in a Tabulator table back to its previous value.
#' This is useful when validation fails or when you want to undo a user's edit.
#'
#' @param outputId The output ID of the Tabulator table (string).
#' @param index The row index (1-based) of the cell to revert.
#' @param field The field name (column name) of the cell to revert.
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @details
#' This function calls Tabulator's `cell.restoreOldValue()` method, which reverts
#' the cell to the value it had before the most recent edit.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$my_table, {
#'   event <- input$my_table
#'
#'   if (event$action == "cellEdited" && event$value < 0) {
#'     # Revert negative values
#'     tabulatorRevertField("my_table", event$index, event$field)
#'   }
#' })
#' }
#'
#' @export
tabulatorRevertField <- function(outputId, index, field, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("tabulatorRevertField must be called from within a Shiny server function")
  }

  session$sendCustomMessage("tabulator-revert-field", list(
    id = session$ns(outputId),
    index = index,
    field = field
  ))
}
