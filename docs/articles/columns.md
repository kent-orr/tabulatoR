# Column Specifications

``` r
library(tabulatoR)
```

## Introduction

This vignette covers how to define and customize columns in tabulatoR
tables. For complete details on all available column options, refer to
the [official Tabulator documentation on
columns](http://tabulator.info/docs/5.6/columns).

tabulatoR provides the
[`Column()`](https://kent-orr.github.io/tabulatoR/reference/Column.md)
helper function to define column specifications that map directly to
Tabulator’s column definition format. All Tabulator column options are
supported through
[`Column()`](https://kent-orr.github.io/tabulatoR/reference/Column.md).

**Note:** The examples in this vignette show Shiny server code. To use
them in your Shiny app, place them inside your `server` function.

## Basic Column Generation

### Auto-Generated Columns

By default, tabulatoR will automatically generate columns from your
data:

``` r
# Create sample data
data <- data.frame(
  id = 1:5,
  name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
  age = c(28, 34, 23, 45, 31),
  department = c("Sales", "Engineering", "Sales", "HR", "Engineering")
)

# In your Shiny server function:
output$table <- renderTabulatoR({
  data
}, autoColumns = TRUE)
```

### Explicit Column Definitions

For more control, define columns explicitly using
[`Column()`](https://kent-orr.github.io/tabulatoR/reference/Column.md):

``` r
# In your Shiny server function:
output$table <- renderTabulatoR({
  data
},
columns = c(
  Column(title = "ID", field = "id"),
  Column(title = "Employee Name", field = "name"),
  Column(title = "Age", field = "age"),
  Column(title = "Department", field = "department")
),
autoColumns = FALSE
)
```

### Common Column Options

The
[`Column()`](https://kent-orr.github.io/tabulatoR/reference/Column.md)
function accepts all standard Tabulator column options:

``` r
# Set width explicitly
Column(title = "ID", field = "id", width = "60px")

# Control horizontal alignment
Column(title = "Name", field = "name", hozAlign = "left")
Column(title = "Age", field = "age", hozAlign = "right")

# Make column resizable
Column(title = "Department", field = "department", resizable = TRUE)

# Hide a column
Column(title = "Internal ID", field = "internal_id", visible = FALSE)
```

## Editable Columns and Editor Types

### Making Columns Editable

Enable editing by setting `editor` or `editable`:

``` r
# Method 1: Set editor explicitly (editable is automatically TRUE)
Column(title = "Name", field = "name", editor = "input")

# Method 2: Set editable = TRUE (Tabulator auto-detects editor type)
Column(title = "Age", field = "age", editable = TRUE)

# Method 3: Make all auto-generated columns editable in renderTabulatoR
output$table <- renderTabulatoR({
  data
}, editable = TRUE)
```

### Built-in Editor Types

tabulatoR supports all Tabulator editor types:

``` r
# Text input editor (single-line)
Column(title = "Name", field = "name", editor = "input")

# Number editor with validation
Column(
  title = "Age",
  field = "age",
  editor = "number",
  editorParams = list(min = 0, max = 120, step = 1)
)

# Textarea editor (multi-line text)
Column(title = "Notes", field = "notes", editor = "textarea")

# Select dropdown
Column(
  title = "Department",
  field = "department",
  editor = "select",
  editorParams = list(values = c("Sales", "Engineering", "Marketing", "HR"))
)

# Checkbox editor
Column(
  title = "Active",
  field = "active",
  editor = "tickCross",
  hozAlign = "center"
)

# Date editor
Column(
  title = "Start Date",
  field = "start_date",
  editor = "date"
)

# Read-only column (no editor)
Column(title = "ID", field = "id", editable = FALSE)
```

### Editor Parameters

Customize editor behavior with `editorParams`:

``` r
# Number editor with constraints
Column(
  title = "Score",
  field = "score",
  editor = "number",
  editorParams = list(
    min = 0,
    max = 100,
    step = 5,
    elementAttributes = list(maxlength = "3")
  )
)

# Select with custom display values
Column(
  title = "Priority",
  field = "priority",
  editor = "select",
  editorParams = list(
    values = list(
      list(label = "Low Priority", value = "low"),
      list(label = "Medium Priority", value = "medium"),
      list(label = "High Priority", value = "high")
    )
  )
)
```

## Custom Formatters

### Built-in Formatters

Tabulator includes many built-in formatters:

``` r
# Money formatter
Column(
  title = "Price",
  field = "price",
  formatter = "money",
  formatterParams = list(
    decimal = ".",
    thousand = ",",
    symbol = "$",
    precision = 2
  )
)

# Tick/Cross for boolean values
Column(
  title = "Active",
  field = "active",
  formatter = "tickCross",
  hozAlign = "center"
)

# Progress bar
Column(
  title = "Completion",
  field = "completion",
  formatter = "progress",
  formatterParams = list(color = "green")
)

# Link formatter
Column(
  title = "Website",
  field = "url",
  formatter = "link",
  formatterParams = list(target = "_blank")
)
```

### Custom JavaScript Formatters

Create custom cell formatters using the
[`js()`](https://kent-orr.github.io/tabulatoR/reference/js.md) helper
function:

``` r
# Simple custom formatter
Column(
  title = "Price",
  field = "price",
  formatter = js("function(cell) {
    return '$' + cell.getValue().toFixed(2);
  }")
)

# Conditional formatting
Column(
  title = "Status",
  field = "status",
  formatter = js("function(cell) {
    var value = cell.getValue();
    var color = value === 'active' ? 'green' : 'red';
    return '<span style=\"color:' + color + '\">' + value + '</span>';
  }")
)

# Multi-field formatter
Column(
  title = "Full Name",
  field = "full_name",
  formatter = js("function(cell) {
    var data = cell.getData();
    return data.first_name + ' ' + data.last_name;
  }")
)
```

## Row Formatters

Row formatters apply styling or logic to entire rows based on their
data. They are specified at the table level, not in individual columns:

``` r
output$table <- renderTabulatoR({
  data
},
columns = c(
  Column(title = "ID", field = "id"),
  Column(title = "Name", field = "name"),
  Column(title = "Status", field = "status")
),
rowFormatter = js("function(row) {
  var data = row.getData();

  // Highlight active rows in green
  if(data.status === 'active') {
    row.getElement().style.backgroundColor = '#d4edda';
  }

  // Highlight inactive rows in red
  if(data.status === 'inactive') {
    row.getElement().style.backgroundColor = '#f8d7da';
  }

  // Make high-priority rows bold
  if(data.priority === 'high') {
    row.getElement().style.fontWeight = 'bold';
  }
}")
)
```

### Row Formatter Use Cases

``` r
# Zebra striping with custom colors
rowFormatter = js("function(row) {
  if(row.getIndex() % 2 === 0) {
    row.getElement().style.backgroundColor = '#f8f9fa';
  }
}")

# Highlight rows based on threshold
rowFormatter = js("function(row) {
  var amount = row.getData().amount;
  if(amount > 1000) {
    row.getElement().style.backgroundColor = '#fff3cd';
    row.getElement().style.borderLeft = '4px solid #ffc107';
  }
}")

# Disable row interaction based on condition
rowFormatter = js("function(row) {
  if(row.getData().locked) {
    row.getElement().style.opacity = '0.5';
    row.getElement().style.pointerEvents = 'none';
  }
}")
```

## Custom Functions and Event Handlers

### Cell Click Events

Respond to cell clicks with custom JavaScript:

``` r
# Simple alert on click
Column(
  title = "Name",
  field = "name",
  cellClick = js("function(e, cell) {
    alert('Clicked: ' + cell.getValue());
  }")
)

# Send data back to Shiny
Column(
  title = "Actions",
  field = "id",
  cellClick = js("function(e, cell) {
    Shiny.setInputValue('clicked_id', cell.getValue(), {priority: 'event'});
  }")
)
```

### Cell Edited Events

Track when cells are edited:

``` r
Column(
  title = "Name",
  field = "name",
  editor = "input",
  cellEdited = js("function(cell) {
    console.log('Cell edited:', cell.getValue());

    // Send to Shiny
    Shiny.setInputValue('edited_cell', {
      field: cell.getField(),
      value: cell.getValue(),
      row: cell.getData()
    }, {priority: 'event'});
  }")
)
```

### Action Columns

Create custom action buttons in a column using the `formatter` option
with `field = NULL`:

``` r
Column(
  title = "Actions",
  field = NULL,  # No data field
  formatter = js(r'(
    (cell) => {
      const row = cell.getRow();
      const div = document.createElement('div');
      div.style.display = 'flex';
      div.style.gap = '5px';

      // Delete button
      const deleteBtn = document.createElement('button');
      deleteBtn.textContent = 'Delete';
      deleteBtn.className = 'btn btn-danger btn-sm';
      deleteBtn.onclick = () => {
        if(confirm('Delete this row?')) {
          row.delete();
        }
      };
      div.appendChild(deleteBtn);

      // Edit button
      const editBtn = document.createElement('button');
      editBtn.textContent = 'Edit';
      editBtn.className = 'btn btn-primary btn-sm';
      editBtn.onclick = () => {
        Shiny.setInputValue("edit_row", row.getData(), {priority: 'event'});
      };
      div.appendChild(editBtn);

      return div;
    }
  )')
)
```

### Custom Validator Functions

Validate cell input with custom logic:

``` r
# Email validation
Column(
  title = "Email",
  field = "email",
  editor = "input",
  validator = js("function(cell, value) {
    // Email regex validation
    var regex = /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/;
    return regex.test(value);
  }")
)

# Age range validation
Column(
  title = "Age",
  field = "age",
  editor = "number",
  validator = js("function(cell, value) {
    return value >= 18 && value <= 100;
  }")
)
```

## Complete Example

Here’s a comprehensive example combining all the concepts:

``` r
# In your Shiny server function:
output$advanced_table <- renderTabulatoR({
  data.frame(
    id = 1:5,
    name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    email = c("alice@example.com", "bob@example.com",
              "charlie@example.com", "diana@example.com", "eve@example.com"),
    age = c(28, 34, 23, 45, 31),
    salary = c(65000, 85000, 55000, 95000, 72000),
    department = c("Sales", "Engineering", "Sales", "HR", "Engineering"),
    status = c("active", "active", "inactive", "active", "active"),
    completion = c(85, 92, 45, 78, 88)
  )
},
columns = c(
  Column(title = "ID", field = "id", width = "60px", editable = FALSE),

  Column(
    title = "Name",
    field = "name",
    editor = "input",
    cellEdited = js("function(cell) {
      console.log('Name updated:', cell.getValue());
    }")
  ),

  Column(
    title = "Email",
    field = "email",
    editor = "input",
    validator = js("function(cell, value) {
      return /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(value);
    }")
  ),

  Column(
    title = "Age",
    field = "age",
    editor = "number",
    editorParams = list(min = 18, max = 100),
    hozAlign = "right"
  ),

  Column(
    title = "Salary",
    field = "salary",
    formatter = "money",
    formatterParams = list(symbol = "$", thousand = ",", precision = 0),
    hozAlign = "right"
  ),

  Column(
    title = "Department",
    field = "department",
    editor = "select",
    editorParams = list(values = c("Sales", "Engineering", "Marketing", "HR"))
  ),

  Column(
    title = "Status",
    field = "status",
    formatter = js("function(cell) {
      var value = cell.getValue();
      var color = value === 'active' ? 'green' : 'red';
      return '<span style=\"color:' + color + '; font-weight: bold;\">' + value + '</span>';
    }")
  ),

  Column(
    title = "Progress",
    field = "completion",
    formatter = "progress",
    formatterParams = list(color = "blue")
  ),

  Column(
    title = "Actions",
    field = NULL,
    formatter = js(r'(
      (cell) => {
        const btn = document.createElement('button');
        btn.textContent = 'View';
        btn.className = 'btn btn-sm btn-primary';
        btn.onclick = () => {
          Shiny.setInputValue("view_employee", cell.getData(), {priority: 'event'});
        };
        return btn;
      }
    )')
  )
),
rowFormatter = js("function(row) {
  if(row.getData().status === 'inactive') {
    row.getElement().style.backgroundColor = '#f8d7da';
  }
  if(row.getData().completion > 90) {
    row.getElement().style.borderLeft = '4px solid #28a745';
  }
}"),
autoColumns = FALSE
)
```

## Additional Resources

- [Tabulator Column
  Documentation](http://tabulator.info/docs/5.6/columns)
- [Tabulator Formatters](http://tabulator.info/docs/5.6/format)
- [Tabulator Editors](http://tabulator.info/docs/5.6/edit)
- [Tabulator Events](http://tabulator.info/docs/5.6/events)
