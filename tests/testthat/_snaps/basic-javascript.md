# comprehensive JavaScript usage snapshot

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  {
                      "id": 1,
                      "name": "Alice",
                      "price": 50,
                      "status": "active"
                  },
                  {
                      "id": 2,
                      "name": "Bob",
                      "price": 150,
                      "status": "inactive"
                  },
                  {
                      "id": 3,
                      "name": "Charlie",
                      "price": 75,
                      "status": "active"
                  }
              ],
              "columns": [
                  {
                      "title": "ID",
                      "field": "id",
                      "visible": true,
                      "width": "60px",
                      "editable": false
                  },
                  {
                      "title": "Name",
                      "field": "name",
                      "visible": true,
                      "editable": true,
                      "editor": "input",
                      "cellClick": "<js>function(e, cell) { console.log('name clicked'); }<\/js>",
                      "cellEdited": "<js>function(cell) { console.log('name edited'); }<\/js>"
                  },
                  {
                      "title": "Price",
                      "field": "price",
                      "visible": true,
                      "hozAlign": "right",
                      "editable": false,
                      "formatter": "<js>function(cell) { var v = cell.getValue(); return v > 100 ? '<span style=\"color:red\">$' + v + '<\/span>' : '<span style=\"color:green\">$' + v + '<\/span>'; }<\/js>"
                  },
                  {
                      "title": "Status",
                      "field": "status",
                      "visible": true,
                      "editable": true,
                      "editor": "select",
                      "editorParams": {
                          "values": [
                              "active",
                              "inactive",
                              "pending"
                          ],
                          "valuesLookup": "<js>function(cell) { return ['active', 'inactive']; }<\/js>"
                      }
                  }
              ],
              "layout": "fitColumns",
              "groupBy": "status",
              "groupHeader": "<js>function(value, count) { return value + ' (' + count + ')'; }<\/js>",
              "rowFormatter": "<js>function(row) { if(row.getData().status === 'active') row.getElement().style.backgroundColor = '#efe'; }<\/js>",
              "tooltips": "<js>function(cell) { return 'Column: ' + cell.getColumn().getField(); }<\/js>"
          },
          "events": {
              "cellClick": "<js>function(e, cell) { return { action: 'cellClick', field: cell.getField(), value: cell.getValue() }; }<\/js>",
              "rowClick": "<js>function(e, row) { return { action: 'rowClick', data: row.getData() }; }<\/js>"
          }
      }
       

