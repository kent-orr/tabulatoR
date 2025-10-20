library(tabulatoR)
library(shiny)

# Helper function for readable JSON snapshots
expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

# =============================================================================
# JAVASCRIPT SERIALIZATION TESTS
# =============================================================================
# These tests verify that custom JavaScript code wrapped with js() is correctly
# packaged and serialized from R into the JSON payload that Tabulator.js receives.
# The js() function wraps code with <js></js> tags so the JavaScript side can
# identify and evaluate it as executable code rather than strings.

test_that("js() creates properly tagged JavaScript", {
  js_code <- "function(cell) { return cell.getValue() * 2; }"
  result <- js(js_code)

  # Should have tabulatoR_js class
  expect_s3_class(result, "tabulatoR_js")

  # Should be character type
  expect_type(result, "character")

  # Should be wrapped with <js> tags
  expect_match(as.character(result), "^<js>")
  expect_match(as.character(result), "</js>$")

  # Should contain the original code
  expect_match(as.character(result), "function\\(cell\\)")
})

test_that("js() preserves JavaScript code exactly", {
  original_code <- "function(e, cell) { console.log('test'); return cell.getValue(); }"
  result <- js(original_code)
  result_str <- as.character(result)

  # Remove tags and verify content
  content <- gsub("^<js>|</js>$", "", result_str)
  expect_equal(content, original_code)
})

# =============================================================================
# COLUMN JAVASCRIPT OPTIONS
# =============================================================================

test_that("js() works with Column formatter", {
  col <- Column(
    title = "Price",
    field = "price",
    formatter = js("function(cell) { return '$' + cell.getValue(); }")
  )

  # Should have js class
  expect_s3_class(col[[1]]$formatter, "tabulatoR_js")

  # Should contain the function
  expect_match(as.character(col[[1]]$formatter), "function\\(cell\\)")
})

test_that("js() formatter serializes correctly in JSON payload", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(price = c(10, 20, 30))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Price",
          field = "price",
          formatter = js("function(cell) { return '$' + cell.getValue(); }")
        )
      )
    )

    json <- isolate(renderer())

    # JSON should contain the js tags (closing tag is escaped as <\/js> in JSON)
    expect_match(json, "<js>")
    expect_match(json, "<\\\\/js>")

    # Should contain the formatter code
    expect_match(json, "function\\(cell\\)")
    expect_match(json, "getValue")
  })
})

test_that("js() works with Column cellClick", {
  col <- Column(
    title = "Name",
    field = "name",
    cellClick = js("function(e, cell) { alert(cell.getValue()); }")
  )

  expect_s3_class(col[[1]]$cellClick, "tabulatoR_js")
  expect_match(as.character(col[[1]]$cellClick), "alert")
})

test_that("js() cellClick serializes correctly in JSON payload", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = c("Alice", "Bob"))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Name",
          field = "name",
          cellClick = js("function(e, cell) { console.log(cell.getValue()); }")
        )
      )
    )

    json <- isolate(renderer())

    # Should contain cellClick with js tags (closing tag escaped in JSON)
    expect_match(json, "\"cellClick\"")
    expect_match(json, "<js>.*function.*<\\\\/js>")
    expect_match(json, "console\\.log")
  })
})

test_that("js() works with Column cellEdited", {
  col <- Column(
    title = "Name",
    field = "name",
    editor = "input",
    cellEdited = js("function(cell) { console.log('edited:', cell.getValue()); }")
  )

  expect_s3_class(col[[1]]$cellEdited, "tabulatoR_js")
  expect_match(as.character(col[[1]]$cellEdited), "edited")
})

test_that("js() cellEdited serializes correctly in JSON payload", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice")
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Name",
          field = "name",
          editor = "input",
          cellEdited = js("function(cell) { console.log('edited'); }")
        )
      )
    )

    json <- isolate(renderer())

    # Should contain cellEdited callback with js tags (closing tag escaped in JSON)
    expect_match(json, "\"cellEdited\"")
    expect_match(json, "<js>.*edited.*<\\\\/js>")
  })
})

test_that("js() works with custom Column editor", {
  col <- Column(
    title = "Name",
    field = "name",
    editor = js("function(cell, onRendered, success, cancel) { /* custom editor */ }")
  )

  expect_s3_class(col[[1]]$editor, "tabulatoR_js")
  expect_match(as.character(col[[1]]$editor), "custom editor")
})

test_that("js() custom editor serializes correctly in JSON payload", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice")
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Name",
          field = "name",
          editor = js("function(cell, onRendered, success, cancel) { var input = document.createElement('input'); return input; }")
        )
      )
    )

    json <- isolate(renderer())

    # Should contain editor function with js tags (closing tag escaped in JSON)
    expect_match(json, "\"editor\"")
    expect_match(json, "<js>.*function.*cell.*onRendered.*success.*cancel.*<\\\\/js>")
    expect_match(json, "createElement")
  })
})

# =============================================================================
# NESTED JAVASCRIPT IN PARAMETERS
# =============================================================================

test_that("js() works in formatterParams", {
  col <- Column(
    title = "Link",
    field = "url",
    formatter = "link",
    formatterParams = list(
      labelField = "name",
      urlPrefix = "http://",
      target = "_blank",
      onClick = js("function(e, cell) { console.log('link clicked'); }")
    )
  )

  expect_s3_class(col[[1]]$formatterParams$onClick, "tabulatoR_js")
})

test_that("js() in formatterParams serializes correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Google", url = "google.com", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Link",
          field = "url",
          formatter = "link",
          formatterParams = list(
            labelField = "name",
            onClick = js("function(e, cell) { alert('clicked'); }")
          )
        )
      )
    )

    json <- isolate(renderer())

    # Should contain formatterParams with nested onClick js (closing tag escaped in JSON)
    expect_match(json, "\"formatterParams\"")
    expect_match(json, "\"onClick\"")
    expect_match(json, "<js>.*alert.*<\\\\/js>")
  })
})

test_that("js() works in editorParams", {
  col <- Column(
    title = "Status",
    field = "status",
    editor = "select",
    editorParams = list(
      values = c("active", "inactive"),
      autocomplete = TRUE,
      listOnEmpty = TRUE,
      valuesLookup = js("function(cell) { return fetchStatusOptions(cell.getData().id); }")
    )
  )

  expect_s3_class(col[[1]]$editorParams$valuesLookup, "tabulatoR_js")
})

test_that("js() in editorParams serializes correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(status = "active", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Status",
          field = "status",
          editor = "select",
          editorParams = list(
            values = c("active", "inactive"),
            valuesLookup = js("function(cell) { return ['option1', 'option2']; }")
          )
        )
      )
    )

    json <- isolate(renderer())

    # Should contain editorParams with nested valuesLookup js (closing tag escaped in JSON)
    expect_match(json, "\"editorParams\"")
    expect_match(json, "\"valuesLookup\"")
    expect_match(json, "<js>.*function.*cell.*<\\\\/js>")
  })
})

# =============================================================================
# TABLE-LEVEL JAVASCRIPT OPTIONS
# =============================================================================

test_that("js() works with groupHeader", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      dept = rep(c("Sales", "Engineering"), each = 2),
      name = c("Alice", "Bob", "Charlie", "Dave"),
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      autoColumns = FALSE,
      groupBy = "dept",
      groupHeader = js("function(value, count, data, group) { return value + ' (' + count + ' items)'; }")
    )

    json <- isolate(renderer())

    # Should contain groupHeader with js tags (closing tag escaped in JSON)
    expect_match(json, "\"groupHeader\"")
    expect_match(json, "<js>.*function.*value.*count.*<\\\\/js>")
    expect_match(json, "items")
  })
})

test_that("js() works with rowFormatter", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      name = "Alice",
      status = "active",
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      autoColumns = FALSE,
      rowFormatter = js("function(row) { if(row.getData().status === 'active') { row.getElement().style.backgroundColor = '#cfc'; } }")
    )

    json <- isolate(renderer())

    # Should contain rowFormatter with js tags (closing tag escaped in JSON)
    expect_match(json, "\"rowFormatter\"")
    expect_match(json, "<js>.*function.*row.*<\\\\/js>")
    expect_match(json, "backgroundColor")
  })
})

test_that("js() works with tooltip function", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(value = 42)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      autoColumns = FALSE,
      tooltips = js("function(cell) { return 'Value: ' + cell.getValue(); }")
    )

    json <- isolate(renderer())

    # Should contain tooltips function with js tags (closing tag escaped in JSON)
    expect_match(json, "\"tooltips\"")
    expect_match(json, "<js>.*function.*cell.*getValue.*<\\\\/js>")
  })
})

test_that("js() works with initialSort function", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1:3, b = 3:1)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      autoColumns = FALSE,
      initialSort = list(
        list(
          column = "a",
          dir = "asc",
          sorter = js("function(a, b) { return a - b; }")
        )
      )
    )

    json <- isolate(renderer())

    # Should contain custom sorter with js tags (closing tag escaped in JSON)
    expect_match(json, "\"initialSort\"")
    expect_match(json, "\"sorter\"")
    expect_match(json, "<js>.*function.*<\\\\/js>")
  })
})

# =============================================================================
# EVENT HANDLERS
# =============================================================================

test_that("js() works with custom event handlers", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      events = list(
        cellClick = js("function(e, cell) { return { action: 'click', value: cell.getValue() }; }")
      )
    )

    json <- isolate(renderer())

    # Should have events section
    expect_match(json, "\"events\"")

    # Should contain cellClick with js tags (closing tag escaped in JSON)
    expect_match(json, "\"cellClick\"")
    expect_match(json, "<js>.*function.*cell.*<\\\\/js>")
    expect_match(json, "getValue")
  })
})

test_that("js() works with multiple event handlers", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(a = 1, b = 2)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      events = list(
        cellClick = js("function(e, cell) { return { type: 'click', val: cell.getValue() }; }"),
        rowClick = js("function(e, row) { return { type: 'row', data: row.getData() }; }"),
        cellEdited = js("function(cell) { return { edited: cell.getValue() }; }")
      )
    )

    json <- isolate(renderer())

    # All three events should be present
    expect_match(json, "\"cellClick\"")
    expect_match(json, "\"rowClick\"")
    expect_match(json, "\"cellEdited\"")

    # All should have js tags (closing tag escaped in JSON as <\/js>)
    expect_true(length(gregexpr("<js>", json)[[1]]) >= 3)
    expect_true(length(gregexpr("<\\\\/js>", json)[[1]]) >= 3)
  })
})

# =============================================================================
# MULTIPLE JS FUNCTIONS IN SINGLE COLUMN
# =============================================================================

test_that("multiple js() functions in single column serialize correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(name = "Alice", stringsAsFactors = FALSE)
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Name",
          field = "name",
          formatter = js("function(cell) { return cell.getValue().toUpperCase(); }"),
          cellClick = js("function(e, cell) { console.log('clicked'); }"),
          cellEdited = js("function(cell) { console.log('edited'); }"),
          editor = "input"
        )
      )
    )

    json <- isolate(renderer())

    # Should contain all three js functions (closing tags escaped in JSON)
    expect_match(json, "\"formatter\".*<js>.*toUpperCase.*<\\\\/js>")
    expect_match(json, "\"cellClick\".*<js>.*clicked.*<\\\\/js>")
    expect_match(json, "\"cellEdited\".*<js>.*edited.*<\\\\/js>")

    # Should have at least 3 js tag pairs
    expect_true(length(gregexpr("<js>", json)[[1]]) >= 3)
    expect_true(length(gregexpr("<\\\\/js>", json)[[1]]) >= 3)
  })
})

# =============================================================================
# COMPLEX JAVASCRIPT CODE
# =============================================================================

test_that("js() handles multi-line JavaScript code", {
  multiline_js <- "function(cell) {
    var value = cell.getValue();
    if (value > 100) {
      return '<span style=\"color:red\">' + value + '</span>';
    } else {
      return '<span style=\"color:green\">' + value + '</span>';
    }
  }"

  result <- js(multiline_js)
  result_str <- as.character(result)

  # Should contain all lines
  expect_match(result_str, "if \\(value > 100\\)")
  expect_match(result_str, "color:red")
  expect_match(result_str, "color:green")

  # Should still have js tags
  expect_match(result_str, "^<js>")
  expect_match(result_str, "</js>$")
})

test_that("js() handles complex JavaScript with special characters", {
  complex_js <- "function(cell) {
    var data = cell.getData();
    var regex = /[a-zA-Z0-9]+/g;
    var result = data.name.match(regex);
    return result ? result.join('-') : 'N/A';
  }"

  result <- js(complex_js)
  result_str <- as.character(result)

  # Should preserve regex and special characters
  expect_match(result_str, "regex")
  expect_match(result_str, "\\[a-zA-Z0-9\\]")
  expect_match(result_str, "join\\('-'\\)")
})

test_that("complex JavaScript serializes correctly in payload", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(value = c(50, 150, 75))
    rv <- reactiveVal(df)

    renderer <- renderTabulatoR(
      rv(),
      columns = c(
        Column(
          title = "Value",
          field = "value",
          formatter = js("function(cell) {
            var val = cell.getValue();
            var color = val > 100 ? 'red' : 'green';
            return '<span style=\"color:' + color + '\">' + val + '</span>';
          }")
        )
      )
    )

    json <- isolate(renderer())

    # Should contain the complex formatter
    expect_match(json, "var val = cell\\.getValue\\(\\)")
    expect_match(json, "val > 100")
    expect_match(json, "color = val > 100")
  })
})

test_that("js() handles arrow functions", {
  arrow_fn <- "(cell) => cell.getValue() * 2"
  result <- js(arrow_fn)
  result_str <- as.character(result)

  expect_match(result_str, "\\(cell\\) =>")
  expect_match(result_str, "getValue\\(\\) \\* 2")
})

test_that("js() handles async functions", {
  async_fn <- "async function(cell) {
    const data = await fetchData(cell.getValue());
    return data;
  }"

  result <- js(async_fn)
  result_str <- as.character(result)

  expect_match(result_str, "async function")
  expect_match(result_str, "await fetchData")
})

# =============================================================================
# COMPREHENSIVE SNAPSHOT
# =============================================================================

test_that("comprehensive JavaScript usage snapshot", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    df <- data.frame(
      id = 1:3,
      name = c("Alice", "Bob", "Charlie"),
      price = c(50, 150, 75),
      status = c("active", "inactive", "active"),
      stringsAsFactors = FALSE
    )
    rv <- reactiveVal(df)

    cols <- c(
      Column(
        title = "ID",
        field = "id",
        width = "60px"
      ),
      Column(
        title = "Name",
        field = "name",
        editor = "input",
        cellClick = js("function(e, cell) { console.log('name clicked'); }"),
        cellEdited = js("function(cell) { console.log('name edited'); }")
      ),
      Column(
        title = "Price",
        field = "price",
        formatter = js("function(cell) { var v = cell.getValue(); return v > 100 ? '<span style=\"color:red\">$' + v + '</span>' : '<span style=\"color:green\">$' + v + '</span>'; }"),
        hozAlign = "right"
      ),
      Column(
        title = "Status",
        field = "status",
        editor = "select",
        editorParams = list(
          values = c("active", "inactive", "pending"),
          valuesLookup = js("function(cell) { return ['active', 'inactive']; }")
        )
      )
    )

    renderer <- renderTabulatoR(
      rv(),
      columns = cols,
      layout = "fitColumns",
      groupBy = "status",
      groupHeader = js("function(value, count) { return value + ' (' + count + ')'; }"),
      rowFormatter = js("function(row) { if(row.getData().status === 'active') row.getElement().style.backgroundColor = '#efe'; }"),
      tooltips = js("function(cell) { return 'Column: ' + cell.getColumn().getField(); }"),
      events = list(
        cellClick = js("function(e, cell) { return { action: 'cellClick', field: cell.getField(), value: cell.getValue() }; }"),
        rowClick = js("function(e, row) { return { action: 'rowClick', data: row.getData() }; }")
      )
    )

    json <- isolate(renderer())

    # Snapshot the complete structure
    expect_snapshot_json(json)
  })
})
