# renderTabulatoR generates expected payload

    Code
      jsonlite::prettify(x)
    Output
      {
          "options": {
              "data": [
                  {
                      "a": [
                          1
                      ],
                      "b": [
                          "x"
                      ]
                  },
                  {
                      "a": [
                          2
                      ],
                      "b": [
                          "y"
                      ]
                  }
              ],
              "columns": [
                  {
                      "title": "a",
                      "field": "a",
                      "editor": true
                  },
                  {
                      "title": "b",
                      "field": "b",
                      "editor": true
                  }
              ],
              "layout": "fitColumns"
          },
          "events": null
      }
       

