# complete table snapshot matches expected Tabulator-compatible format

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  {
                      "id": 1,
                      "name": "Alice",
                      "age": 25
                  },
                  {
                      "id": 2,
                      "name": "Bob",
                      "age": 30
                  },
                  {
                      "id": 3,
                      "name": "Charlie",
                      "age": 35
                  }
              ],
              "columns": [
                  {
                      "title": "ID",
                      "field": "id",
                      "visible": true,
                      "hozAlign": "center",
                      "width": "60px",
                      "editable": false
                  },
                  {
                      "title": "Name",
                      "field": "name",
                      "visible": true,
                      "editable": true,
                      "editor": "input"
                  },
                  {
                      "title": "Age",
                      "field": "age",
                      "visible": true,
                      "hozAlign": "right",
                      "editable": true,
                      "editor": "number"
                  }
              ],
              "layout": "fitColumns"
          },
          "events": {
      
          }
      }
       

# minimal table produces valid Tabulator-compatible output

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  [
                      1
                  ],
                  [
                      2
                  ]
              ],
              "columns": [
                  {
                      "title": "a",
                      "field": "a",
                      "editor": true
                  }
              ],
              "layout": "fitColumns"
          },
          "events": {
      
          }
      }
       

