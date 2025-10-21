#' Add row(s) to a Tabulator table
#'
#' @description
#' Programmatically adds one or more rows to an existing Tabulator table in a Shiny app.
#' This function sends a message to the JavaScript binding to add rows to the table
#' without re-rendering the entire widget or modifying the underlying R data.
#'
#' @param outputId The output ID of the Tabulator table (string).
#' @param data A data.frame or list representing the row(s) to add.
#' @param add_to Where to add the row(s): `"top"` or `"bottom"`. Default is `"bottom"`.
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
#'   tabulatorAddRow("my_table", new_row, add_to = "top")
#' })
#' }
#'
#' @export
tabulatorAddRow <- function(outputId, data, add_to = "bottom", session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("tabulatorAddRow must be called from within a Shiny server function")
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


#' Remove row(s) from a Tabulator table
#'
#' @description
#' Programmatically removes row(s) from an existing Tabulator table in a Shiny app
#' by their index position(s). This function sends a message to the JavaScript binding
#' to remove rows from the table without re-rendering the entire widget or modifying
#' the underlying R data.
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
#'   tabulatorRemoveRow("my_table", index = 1)  # Remove first row
#' })
#' }
#'
#' @export
tabulatorRemoveRow <- function(outputId, index, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("tabulatorRemoveRow must be called from within a Shiny server function")
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


#' Set data in a Tabulator spreadsheet
#'
#' @description
#' Programmatically loads data into an existing Tabulator spreadsheet in a Shiny app.
#' This function sends a message to the JavaScript binding to set the spreadsheet data
#' without re-rendering the entire widget.
#'
#' The function automatically converts data.frames and matrices to the array-of-arrays
#' format required by Tabulator spreadsheets.
#'
#' This function calls Tabulator's `setData()` method. For more information, see:
#' \url{https://tabulator.info/docs/6.3/data#array}
#'
#' @param outputId The output ID of the Tabulator spreadsheet (string).
#' @param data A data.frame, matrix, or list of lists representing the spreadsheet data.
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @details
#' Unlike standard Tabulator tables, spreadsheets use an array-of-arrays data format
#' where each row is a list and data is accessed by position rather than field names.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$load_data_btn, {
#'   new_data <- data.frame(
#'     A = 1:10,
#'     B = 11:20,
#'     C = 21:30
#'   )
#'   spreadsheetSetData("my_spreadsheet", new_data)
#' })
#' }
#'
#' @export
spreadsheetSetData <- function(outputId, data, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("spreadsheetSetData must be called from within a Shiny server function")
  }

  # Convert to array-of-arrays format
  data_array <- to_array_of_arrays(data)

  session$sendCustomMessage("spreadsheet-set-data", list(
    id = session$ns(outputId),
    data = data_array
  ))
}


#' Clear all data from a Tabulator spreadsheet
#'
#' @description
#' Programmatically clears all data from an existing Tabulator spreadsheet in a Shiny app.
#' This function sends a message to the JavaScript binding to clear the spreadsheet
#' without re-rendering the entire widget.
#'
#' This function calls Tabulator's `clearSheet()` method. For more information, see:
#' \url{https://tabulator.info/docs/6.3/spreadsheet#clear}
#'
#' @param outputId The output ID of the Tabulator spreadsheet (string).
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @details
#' This calls Tabulator's `clearSheet()` method, which removes all data but preserves
#' the spreadsheet configuration and structure.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$clear_btn, {
#'   spreadsheetClearSheet("my_spreadsheet")
#' })
#' }
#'
#' @export
spreadsheetClearSheet <- function(outputId, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("spreadsheetClearSheet must be called from within a Shiny server function")
  }

  session$sendCustomMessage("spreadsheet-clear-sheet", list(
    id = session$ns(outputId)
  ))
}


#' Request current data from a Tabulator spreadsheet
#'
#' @description
#' Programmatically requests the current data from a Tabulator spreadsheet.
#' This function sends a message to the JavaScript binding to retrieve the
#' spreadsheet data, which will be sent back to Shiny as an input value.
#'
#' This function calls Tabulator's `getData()` method. For more information, see:
#' \url{https://tabulator.info/docs/6.3/data#retrieve}
#'
#' @param outputId The output ID of the Tabulator spreadsheet (string).
#' @param session The Shiny session object. Defaults to `shiny::getDefaultReactiveDomain()`.
#'
#' @details
#' After calling this function, the spreadsheet data will be available in
#' `input$<outputId>_data` as a list of lists (array-of-arrays format).
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' observeEvent(input$get_data_btn, {
#'   spreadsheetGetData("my_spreadsheet")
#' })
#'
#' # Access the data in a reactive context
#' observe({
#'   data <- input$my_spreadsheet_data
#'   if (!is.null(data)) {
#'     print(data)
#'   }
#' })
#' }
#'
#' @export
spreadsheetGetData <- function(outputId, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("spreadsheetGetData must be called from within a Shiny server function")
  }

  session$sendCustomMessage("spreadsheet-get-data", list(
    id = session$ns(outputId)
  ))
}
