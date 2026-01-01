# complex configuration with multiple options snapshot

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  {
                      "id": 1,
                      "name": "Person 1",
                      "dept": "Sales",
                      "age": 25,
                      "status": "active"
                  },
                  {
                      "id": 2,
                      "name": "Person 2",
                      "dept": "Engineering",
                      "age": 28,
                      "status": "inactive"
                  },
                  {
                      "id": 3,
                      "name": "Person 3",
                      "dept": "HR",
                      "age": 31,
                      "status": "active"
                  },
                  {
                      "id": 4,
                      "name": "Person 4",
                      "dept": "Sales",
                      "age": 34,
                      "status": "inactive"
                  },
                  {
                      "id": 5,
                      "name": "Person 5",
                      "dept": "Engineering",
                      "age": 37,
                      "status": "active"
                  },
                  {
                      "id": 6,
                      "name": "Person 6",
                      "dept": "HR",
                      "age": 40,
                      "status": "inactive"
                  },
                  {
                      "id": 7,
                      "name": "Person 7",
                      "dept": "Sales",
                      "age": 43,
                      "status": "active"
                  },
                  {
                      "id": 8,
                      "name": "Person 8",
                      "dept": "Engineering",
                      "age": 46,
                      "status": "inactive"
                  },
                  {
                      "id": 9,
                      "name": "Person 9",
                      "dept": "HR",
                      "age": 49,
                      "status": "active"
                  },
                  {
                      "id": 10,
                      "name": "Person 10",
                      "dept": "Sales",
                      "age": 52,
                      "status": "inactive"
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
                      "title": "Department",
                      "field": "dept",
                      "visible": true,
                      "editable": false
                  },
                  {
                      "title": "Age",
                      "field": "age",
                      "visible": true,
                      "hozAlign": "right",
                      "editable": false
                  },
                  {
                      "title": "Status",
                      "field": "status",
                      "visible": true,
                      "editable": false
                  }
              ],
              "layout": "fitColumns",
              "height": "400px",
              "pagination": true,
              "paginationSize": 10,
              "paginationSizeSelector": [
                  10,
                  25,
                  50
              ],
              "initialSort": [
                  {
                      "column": "name",
                      "dir": "asc"
                  }
              ],
              "groupBy": "dept",
              "groupStartOpen": true,
              "selectable": true,
              "tooltips": true,
              "movableColumns": true,
              "responsiveLayout": "collapse"
          },
          "events": null
      }
       

