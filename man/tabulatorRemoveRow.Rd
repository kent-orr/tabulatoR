% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/render.R
\name{tabulatorRemoveRow}
\alias{tabulatorRemoveRow}
\title{Remove a row from a Tabulator table by index}
\usage{
tabulatorRemoveRow(id, index, session = getDefaultReactiveDomain())
}
\arguments{
\item{id}{The ID of the Tabulator table.}

\item{index}{An integer index corresponding to the Tabulator row index.
Use the \code{index} value from an event payload (e.g., \code{input$my_table$cellClick$index}).}

\item{session}{The Shiny session object.}
}
\description{
Removes a row from the table using Tabulator's internal row index system.
This is not the R row number — it is the index returned from a Tabulator event
(e.g., \code{input$my_table$rowClick$index}).
}
