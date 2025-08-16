# ActionColumn returns expected list

    Code
      ActionColumn("Edit", "edit")
    Output
      [[1]]
      [[1]]$title
      [1] "Edit"
      
      [[1]]$field
      [1] "edit"
      
      [[1]]$visible
      [1] TRUE
      
      [[1]]$editable
      [1] FALSE
      
      [[1]]$formatter
      [1] "<js>function(cell, formatterParams, onRendered) {\n  const el = cell.getElement();\n  const Button = document.createElement('button');\n  Button.className = \"btn btn-primary\";\n  Button.innerHTML = \"Edit\";\n  Button.onclick = function() {\n    const table = cell.getTable();\n    const inputId = table.id;\n    const inputVal = Shiny.shinyapp.$inputValues[inputId] || {};\n    inputVal[\"edit\"] = {\n      event: \"edit\",\n      field: cell.getField(),\n      value: flattenData(cell.getValue()),\n      row: flattenData(cell.getRow().getData()),\n      position: flattenData(cell.getRow().getPosition())\n    };\n    Shiny.setInputValue(inputId, inputVal, { priority: 'event' });\n  };\n  el.appendChild(Button);\n}</js>"
      attr(,"class")
      [1] "tabulatoR_js"
      
      

# ActionColumn supports icons

    Code
      ActionColumn("Edit", "edit", icon = shiny::icon("edit"))
    Output
      [[1]]
      [[1]]$title
      [1] "Edit"
      
      [[1]]$field
      [1] "edit"
      
      [[1]]$visible
      [1] TRUE
      
      [[1]]$editable
      [1] FALSE
      
      [[1]]$formatter
      [1] "<js>function(cell, formatterParams, onRendered) {\n  const el = cell.getElement();\n  const Button = document.createElement('button');\n  Button.className = \"btn btn-primary\";\n  Button.innerHTML = \"<i class=\\\"far fa-pen-to-square\\\" role=\\\"presentation\\\" aria-label=\\\"pen-to-square icon\\\"><\\/i> Edit\";\n  Button.onclick = function() {\n    const table = cell.getTable();\n    const inputId = table.id;\n    const inputVal = Shiny.shinyapp.$inputValues[inputId] || {};\n    inputVal[\"edit\"] = {\n      event: \"edit\",\n      field: cell.getField(),\n      value: flattenData(cell.getValue()),\n      row: flattenData(cell.getRow().getData()),\n      position: flattenData(cell.getRow().getPosition())\n    };\n    Shiny.setInputValue(inputId, inputVal, { priority: 'event' });\n  };\n  el.appendChild(Button);\n}</js>"
      attr(,"class")
      [1] "tabulatoR_js"
      
      

