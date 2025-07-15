library(shiny)
library(bslib)
devtools::load_all()  # Use this if you're testing a local package

ui <- page_fillable(
    theme = bs_theme(version = 5),
    tags$head(
      tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css")
    ),
    tags$h2("TabulatoR Debug App"),

    actionButton('add_row', 'Add a Row'),
    tabulatoROutput('table'),
    shiny::tags$p(),
    verbatimTextOutput("debug_output")
)

server <- function(input, output, session) {
  # Reactive data that changes when the button is clicked
  datum <- reactiveVal({
    x = head(mtcars)
    x$id = seq_len(nrow(x))
    x
  })

  # Send data to Tabulator
  output$table <- renderTabulatoR(
    datum(),
    columns = c(
        Column('MPG', 'mpg', editable=TRUE, editor = 'input')
        , Column('Cyl', 'cyl')
        , Column('Disp', 'disp')
        , Column('HP', 'hp')
        , Column('Actions', field=NULL, formatter = js(
            r'(
            (cell) => {
                const row = cell.getRow();
                const el = cell.getElement();
                const div = document.createElement('div');
                div.style.display = "flex";
                div.style.gap = "5px"; // Add some space between buttons
            
                // Delete button
                const deleteButton = document.createElement('button');
                deleteButton.className = "btn btn-sm btn-outline-danger";
                const deleteIcon = document.createElement('i');
                deleteIcon.className = "fas fa-trash-alt";
                deleteButton.appendChild(deleteIcon);
                deleteButton.onclick = () => {
                    row.delete();
                    console.log("Deleted row:", row.getData());
                }
                div.appendChild(deleteButton);
            
                // Display button
                const displayButton = document.createElement('button');
                displayButton.className = "btn btn-sm btn-outline-info";
                const displayIcon = document.createElement('i');
                displayIcon.className = "fas fa-eye";
                displayButton.appendChild(displayIcon);
                displayButton.onclick = () => {
                    console.log("Display row:", row.getData());
                    Shiny.setInputValue("view_row", flattenData(row.getData()), {priority: 'event'});
                }
                div.appendChild(displayButton); // Fixed: appendChild with capital C
            
                el.appendChild(div);
                return div;
            }
            )'
        ))
    )
  )

  observeEvent(input$add_row, {
    showModal(
        modalDialog(
            title = "Add a New Row",
            size = "m",
            easyClose = TRUE,
            footer = tagList(
                actionButton("add_row_confirm", "Add")
            ),
            textInput("new_row_name", "Name", value = "Batmobile"),
            numericInput("new_row_mpg", "MPG", value = 21),
            numericInput("new_row_cyl", "Cyl", value = 4),
    ))
  })

  observeEvent(input$add_row_confirm, {
    x = datum()
    y = x[1,]
    for (col in names(y)) {
        y[[col]] <- NA
    }
    
    y$id = max(datum()$id) + 1
    y$mpg = input$new_row_mpg
    y$cyl = input$new_row_cyl
    
    row.names(y) <- input$new_row_name
    tabulatorAddData('table', y)
    z = rbind(x, y)
    datum(z)
    removeModal()
  })

  # Update data when user edits the table
  observeEvent(input$table, {
    edit = input$table
    # makes an edit
    if (!is.null(edit$cellEdited)) {
        edit <- edit$cellEdited
        id = edit$row$id
        x <- datum()
        x[x$id == id,][[edit$field]] <- edit$value
        datum(x)
        showNotification(paste("Edited row:", id, edit$field, edit$value))
    # delete a row
    } else if (!is.null(edit$rowDeleted)) {
        edit = edit$rowDeleted
        id = edit$row$id
        x <- datum()
        x <- x[x$id!= id,]
        datum(x)
        showNotification(paste("Deleted row:", id))
    # add a new row
    } else if (!is.null(edit$rowAdded)) {
        
    }

  })

  observeEvent(input$view_row, {
    names = row.names(datum())
    id = input$view_row$id
    car = names[which(datum()$id == id)]
    showNotification(paste("Viewing", car, "with id", id), type="message")
  })

  # Show data in console
  output$debug_output <- renderPrint({
    list(
      data = datum(),
      inputs =  str(reactiveValuesToList(input))
    )
  })
}

shinyApp(ui, server)

