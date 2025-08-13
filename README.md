# tabulatoR

tabulatoR is an R package that brings the powerful [Tabulator JavaScript library](https://tabulator.info/) to Shiny applications. It provides a lightweight yet highly extensible wrapper around Tabulator, designed specifically for interactive data tables in R.

## Why Choose tabulatoR?

### Column-First Design Philosophy
Unlike other R table packages that work primarily at the table level, tabulatoR follows Tabulator's **column-declarative schema**. This means you define your table by specifying individual columns and their properties, rather than applying formatting to the entire table after creation. This approach offers several advantages:

- **Precision**: Configure exactly how each field should behave, look, and interact
- **Maintainability**: Column definitions are self-contained and reusable
- **Flexibility**: Different columns can have completely different behaviors within the same table

### Seamless JavaScript Integration
One of tabulatoR's standout features is its ability to embed custom JavaScript directly within R column definitions. This means:

- **Immediate customization**: No need to write separate JS files or complex bindings
- **Boundless extensibility**: Access the full Tabulator API directly from R
- **Learning curve**: If you know a little JavaScript, you can customize anything

### Built for Shiny Interactivity
While other table packages were adapted for Shiny, tabulatoR was designed from the ground up for reactive applications:

- **Event-driven**: Rich set of built-in event handlers for user interactions
- **Real-time updates**: Seamless data synchronization between R and the browser
- **Reactive-friendly**: Works naturally with Shiny's reactive programming model

### Example: The Difference in Approach

**Traditional table packages (row/table-focused):**
```r
# Configure the entire table, then apply formatting
datatable(data) %>% 
  formatCurrency(columns = "price") %>%
  formatDate(columns = "date")
```

tabulatoR (column-focused):

```r
# Define each column's behavior upfront
renderTabulatoR(
  data(),
  columns = list(
    Column("Price", "price", formatter = "money"),
    Column("Date", "date", formatter = "datetime"),
    ActionColumn("Edit", "edit_btn")
  )
)
```

This column-first approach makes complex interactive tables more intuitive to build and maintain.


## Getting Started

### Installation

You can install tabulatoR from GitHub:

```r
# Install from GitHub
devtools::install_github("your-username/tabulatoR")

# Load the package
library(tabulatoR)
library(shiny)
```

## Creating a basic table for display
Your First tabulatoR Table
The simplest way to create a table is to use renderTabulatoR() in your Shiny server and tabulatoROutput() in your UI:

```r
library(shiny)
library(tabulatoR)

ui <- fluidPage(
  titlePanel("My First tabulatoR Table"),
  tabulatoROutput("my_table")
)

server <- function(input, output, session) {
  output$my_table <- renderTabulatoR({
    mtcars
  })
}

shinyApp(ui, server)
```

This creates a basic table with automatic column detection - tabulatoR will create columns for each field in your data frame.

### Understanding Your Data

When you pass a data frame to renderTabulatoR(), several things happen automatically:

- Column names become table headers  
- Data types are detected and appropriate formatters are applied  
- All columns are made visible by default  
- Basic sorting is enabled on all columns  

For example, with the mtcars dataset:

- Numeric columns like mpg and hp get number formatting  
- The row names become a special index column  
- All 11 columns are displayed with their original names  

### Declaring Custom Columns

While automatic column detection is convenient, the real power of tabulatoR comes from explicit column declarations. Use the columns parameter to define exactly how each column should behave:

```r
output$my_table <- renderTabulatoR(
  mtcars,
  columns = list(
    Column("Miles per Gallon", "mpg", width = 150),
    Column("Cylinders", "cyl", width = 100),
    Column("Horsepower", "hp", width = 120),
    Column("Weight", "wt", formatter = "money", 
           formatterParams = list(precision = 0))
  )
)
```

### Column Declaration Benefits
Custom titles: Use human-readable names instead of variable names
Column("Miles per Gallon", "mpg")  # Display name vs. field name
Width control: Set exact pixel widths for consistent layouts
Column("ID", "id", width = 80)
Column("Description", "desc", width = 300)
Data formatting: Apply built-in formatters for better presentation
Column("Price", "price", formatter = "money")
Column("Date", "created_at", formatter = "datetime")
Column("Progress", "completion", formatter = "progress")
Visibility control: Hide columns that shouldn't be displayed
Column("Internal ID", "internal_id", visible = FALSE)




## Making a column editable
- talk about editors
- briefly mention that editorcs can be formatted

## Listening for events
- talk abou the naming convention for the inputs sent to the shiny app
- talk about the basic default event listeners
- talk about how to make your own custom logic in a column def if you need to

## Differences from other interactive tables
- talk about why we don't use a proxy API here and instead just talk to the table model directly