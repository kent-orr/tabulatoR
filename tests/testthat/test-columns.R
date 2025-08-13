library(tabulatoR)

# Tests for Column

test_that("Column returns expected list", {
  expected <- list(list(title = "Name", field = "name", visible = TRUE, editable = FALSE))
  expect_equal(Column("Name", "name"), expected)
})

# Tests for ActionColumn

test_that("ActionColumn returns expected list", {
  js_code <- glue::glue(
    "\n  function(cell, formatterParams, onRendered) {\n    const el = cell.getElement();\n    const Button = document.createElement('button');\n    Button.textContent = 'Edit';\n    Button.className = 'btn btn-primary';\n    Button.onclick = function() {\n      const table = cell.getTable();\n      const inputId = table.id;\n      const inputVal = Shiny.shinyapp.$inputValues[inputId] || {};\n      inputVal['edit'] = {\n        event: 'edit',\n        field: cell.getField(),\n        value: flattenData(cell.getValue()),\n        row: flattenData(cell.getRow().getData()),\n        position: flattenData(cell.getRow().getPosition())\n      };\n      Shiny.setInputValue(inputId, inputVal, { priority: 'event' });\n    };\n    el.appendChild(Button);\n  }\n  ", .open = "<<", .close = ">>")
  expected <- Column(
    title = "Edit",
    field = "edit",
    formatter = htmlwidgets::JS(js_code)
  )
  expect_equal(ActionColumn("Edit", "edit"), expected)
})
