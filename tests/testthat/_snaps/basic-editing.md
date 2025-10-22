# mixed editable and non-editable columns

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  {
                      "id": [
                          1
                      ],
                      "name": [
                          "Alice"
                      ],
                      "age": [
                          25
                      ]
                  }
              ],
              "columns": [
                  {
                      "title": "ID",
                      "field": "id",
                      "visible": true,
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
                      "editable": true,
                      "editor": true
                  }
              ],
              "layout": "fitColumns"
          },
          "events": null
      }
       

# complete editing snapshot with various editor types

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  {
                      "id": [
                          1
                      ],
                      "name": [
                          "Alice"
                      ],
                      "age": [
                          25
                      ],
                      "status": [
                          "active"
                      ],
                      "notes": [
                          "Note 1"
                      ]
                  },
                  {
                      "id": [
                          2
                      ],
                      "name": [
                          "Bob"
                      ],
                      "age": [
                          30
                      ],
                      "status": [
                          "inactive"
                      ],
                      "notes": [
                          "Note 2"
                      ]
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
                      "editor": "input"
                  },
                  {
                      "title": "Age",
                      "field": "age",
                      "visible": true,
                      "editable": true,
                      "editor": "number"
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
                          ]
                      }
                  },
                  {
                      "title": "Notes",
                      "field": "notes",
                      "visible": true,
                      "editable": true,
                      "editor": "textarea"
                  }
              ],
              "layout": "fitColumns"
          },
          "events": null
      }
       

