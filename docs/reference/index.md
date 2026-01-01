# Package index

## Core Functions

Main functions for creating Tabulator tables

- [`renderTabulatoR()`](https://kent-orr.github.io/tabulatoR/reference/renderTabulatoR.md)
  : Render a Tabulator Table in Shiny
- [`tabulatoROutput()`](https://kent-orr.github.io/tabulatoR/reference/tabulatoROutput.md)
  : Create a Tabulator Output Element

## Column Definition

Functions for defining and customizing columns

- [`Column()`](https://kent-orr.github.io/tabulatoR/reference/Column.md)
  : Define a Tabulator Column
- [`flatten_columns()`](https://kent-orr.github.io/tabulatoR/reference/flatten_columns.md)
  : Flatten nested column lists into a flat list of column objects

## Table Operations

Functions for updating tables reactively

- [`tabulatorAddRow()`](https://kent-orr.github.io/tabulatoR/reference/tabulatorAddRow.md)
  : Add row(s) to a Tabulator table
- [`tabulatorRemoveRow()`](https://kent-orr.github.io/tabulatoR/reference/tabulatorRemoveRow.md)
  : Remove row(s) from a Tabulator table
- [`tabulatorReplaceData()`](https://kent-orr.github.io/tabulatoR/reference/tabulatorReplaceData.md)
  : Replace all data in a Tabulator table
- [`tabulatorRevertField()`](https://kent-orr.github.io/tabulatoR/reference/tabulatorRevertField.md)
  : Revert a cell to its previous value

## Spreadsheet Mode

Functions for spreadsheet-like functionality

- [`renderSpreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/renderSpreadsheet.md)
  : Render a Tabulator Spreadsheet in Shiny
- [`spreadsheetOutput()`](https://kent-orr.github.io/tabulatoR/reference/spreadsheetOutput.md)
  : Output element for a Tabulator spreadsheet
- [`spreadsheetGetData()`](https://kent-orr.github.io/tabulatoR/reference/spreadsheetGetData.md)
  : Request current data from a Tabulator spreadsheet
- [`spreadsheetSetData()`](https://kent-orr.github.io/tabulatoR/reference/spreadsheetSetData.md)
  : Set data in a Tabulator spreadsheet
- [`spreadsheetClearSheet()`](https://kent-orr.github.io/tabulatoR/reference/spreadsheetClearSheet.md)
  : Clear all data from a Tabulator spreadsheet

## Preview Functions

Functions for previewing tables

- [`preview_static()`](https://kent-orr.github.io/tabulatoR/reference/preview_static.md)
  : Preview a static Tabulator table
- [`preview_crud()`](https://kent-orr.github.io/tabulatoR/reference/preview_crud.md)
  : Preview a Tabulator table with basic CRUD
- [`preview_spreadsheet()`](https://kent-orr.github.io/tabulatoR/reference/preview_spreadsheet.md)
  : Preview a Tabulator spreadsheet

## JavaScript Utilities

Helper functions for JavaScript integration

- [`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) : tag
  javascript for rendering in tabulatoR

## Internal Utilities

Helper functions for data transformation

- [`tab_source()`](https://kent-orr.github.io/tabulatoR/reference/tab_source.md)
  : Generate Tabulator Source Links
- [`to_array_of_arrays()`](https://kent-orr.github.io/tabulatoR/reference/to_array_of_arrays.md)
  : Convert data.frame or matrix to array-of-arrays format
