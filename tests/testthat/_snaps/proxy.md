# tabulatorReplaceData sends correct custom message

    Code
      messages[["tabulator-replace-data"]]
    Output
      $id
      [1] "my_id"
      
      $data
      $data[[1]]
        a b
      1 1 x
      
      $data[[2]]
        a b
      2 2 y
      
      

# tabulatorAddData sends correct custom message

    Code
      messages[["tabulator-add-data"]]
    Output
      $id
      [1] "tbl"
      
      $data
      $data[[1]]
        a
      1 3
      
      $data[[2]]
        a
      2 4
      
      
      $addToTop
      [1] FALSE
      

# tabulatorRemoveRow sends correct custom message

    Code
      messages[["tabulator-remove-row"]]
    Output
      $id
      [1] "tbl"
      
      $index
      [1] 5
      

# tabulatorRestoreOldValue sends correct custom message

    Code
      messages[["tabulator-restore-old-value"]]
    Output
      $id
      [1] "tbl"
      
      $index
      [1] 2
      
      $field
      [1] "field"
      

