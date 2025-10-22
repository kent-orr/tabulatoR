library(tabulatoR)
library(shiny)
library(testthat)

# =============================================================================
# SHINY JAVASCRIPT INTEGRATION TESTS
# =============================================================================
# These tests verify that JavaScript functions wrapped with js() work correctly
# in Shiny, including formatters, event handlers, and custom callbacks.

test_that("js() wrapped functions serialize correctly", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column("Name", "name", formatter = js("function(cell) { return cell.getValue().toUpperCase(); }"))
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Verify formatter is present and tagged as JS
    formatter <- payload$options$columns[[1]]$formatter
    expect_type(formatter, "character")
    expect_match(formatter, "<js>")
    expect_match(formatter, "</js>")
  })
})

test_that("custom cellClick event with js() works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Name",
          "name",
          cellClick = js("function(e, cell) { console.log('Clicked:', cell.getValue()); }")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Verify cellClick is present
    cellClick <- payload$options$columns[[1]]$cellClick
    expect_type(cellClick, "character")
    expect_match(cellClick, "<js>")
  })
})

test_that("custom event handlers override defaults", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    custom_handler <- js(r"(
      function(cell) {
        return {
          action: 'customEdit',
          field: cell.getField(),
          value: cell.getValue()
        };
      }
    )")

    renderer <- renderTabulatoR(
      data_rv(),
      events = list(cellEdited = custom_handler)
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Verify custom event handler is present
    expect_true("cellEdited" %in% names(payload$events))
    expect_match(payload$events$cellEdited, "<js>")
  })
})

test_that("multiple js() functions in columns work", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Name",
          "name",
          formatter = js("function(cell) { return cell.getValue(); }"),
          cellClick = js("function(e, cell) { console.log('Click'); }")
        ),
        Column(
          "Age",
          "age",
          formatter = js("function(cell) { return cell.getValue() + ' years'; }")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Both columns should have JS functions
    expect_match(payload$options$columns[[1]]$formatter, "<js>")
    expect_match(payload$options$columns[[1]]$cellClick, "<js>")
    expect_match(payload$options$columns[[2]]$formatter, "<js>")
  })
})

test_that("action column formatter with js() works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column("Name", "name"),
        Column(
          "Actions",
          field = NULL,
          formatter = js(r"(
            function(cell) {
              const btn = document.createElement('button');
              btn.textContent = 'Delete';
              btn.onclick = () => cell.getRow().delete();
              return btn;
            }
          )")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    # Verify action column
    action_col <- payload$options$columns[[2]]
    expect_null(action_col$field)
    expect_match(action_col$formatter, "<js>")
    expect_match(action_col$formatter, "document.createElement")
  })
})

test_that("complex formatter with flattenData works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Actions",
          field = NULL,
          formatter = js(r"(
            function(cell) {
              const row = cell.getRow();
              const btn = document.createElement('button');
              btn.onclick = () => {
                Shiny.setInputValue('clicked_row', flattenData(row.getData()), {priority: 'event'});
              };
              return btn;
            }
          )")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    formatter <- payload$options$columns[[1]]$formatter
    expect_match(formatter, "flattenData")
    expect_match(formatter, "Shiny.setInputValue")
  })
})

test_that("editor with editorParams works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Age",
          "age",
          editor = "number",
          editorParams = list(min = 0, max = 120, step = 1)
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    col <- payload$options$columns[[1]]
    expect_equal(col$editor, "number")
    expect_equal(col$editorParams$min, 0)
    expect_equal(col$editorParams$max, 120)
    expect_equal(col$editorParams$step, 1)
  })
})

test_that("custom editor with js() works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Name",
          "name",
          editor = js(r"(
            function(cell, onRendered, success, cancel) {
              const input = document.createElement('input');
              input.value = cell.getValue();
              input.onblur = () => success(input.value);
              return input;
            }
          )")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    editor <- payload$options$columns[[1]]$editor
    expect_match(editor, "<js>")
    expect_match(editor, "document.createElement")
  })
})

test_that("formatterParams work with standard formatter", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Active",
          "active",
          formatter = "tickCross",
          formatterParams = list(allowEmpty = TRUE, tickElement = "✓", crossElement = "✗")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    col <- payload$options$columns[[1]]
    expect_equal(col$formatter, "tickCross")
    expect_equal(col$formatterParams$allowEmpty, TRUE)
    expect_equal(col$formatterParams$tickElement, "✓")
    expect_equal(col$formatterParams$crossElement, "✗")
  })
})

test_that("cellEdited callback in column works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column(
          "Name",
          "name",
          editor = "input",
          cellEdited = js("function(cell) { console.log('Cell edited:', cell.getValue()); }")
        )
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    cellEdited <- payload$options$columns[[1]]$cellEdited
    expect_match(cellEdited, "<js>")
  })
})

test_that("multiple event types can be configured", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      events = list(
        cellClick = js("function(e, cell) { return {action: 'click', field: cell.getField()}; }"),
        cellEdited = js("function(cell) { return {action: 'edited', field: cell.getField()}; }"),
        rowDeleted = js("function(row) { return {action: 'deleted', row: flattenData(row.getData())}; }"),
        rowAdded = js("function(row) { return {action: 'added', row: flattenData(row.getData())}; }")
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    expect_true("cellClick" %in% names(payload$events))
    expect_true("cellEdited" %in% names(payload$events))
    expect_true("rowDeleted" %in% names(payload$events))
    expect_true("rowAdded" %in% names(payload$events))

    # All should be js-wrapped
    expect_match(payload$events$cellClick, "<js>")
    expect_match(payload$events$cellEdited, "<js>")
    expect_match(payload$events$rowDeleted, "<js>")
    expect_match(payload$events$rowAdded, "<js>")
  })
})

test_that("js() preserves complex JavaScript code", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    complex_js <- js(r"(
      function(cell) {
        const row = cell.getRow();
        const data = row.getData();
        const el = cell.getElement();

        // Complex logic
        if (data.age > 30) {
          el.style.backgroundColor = 'lightblue';
        }

        const div = document.createElement('div');
        div.textContent = data.name;
        return div;
      }
    )")

    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(Column("Name", "name", formatter = complex_js))
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    formatter <- payload$options$columns[[1]]$formatter
    expect_match(formatter, "<js>")
    expect_match(formatter, "const row = cell.getRow")
    expect_match(formatter, "data.age > 30")
    expect_match(formatter, "lightblue")
  })
})

test_that("js() with arrow functions works", {
  session <- MockShinySession$new()
  withReactiveDomain(session, {
    data_rv <- reactive(sample_data())
    renderer <- renderTabulatoR(
      data_rv(),
      columns = c(
        Column("Name", "name", formatter = js("(cell) => cell.getValue().toUpperCase()"))
      )
    )
    json <- isolate(renderer())
    payload <- parse_payload(json)

    formatter <- payload$options$columns[[1]]$formatter
    expect_match(formatter, "<js>")
    expect_match(formatter, "=>")
  })
})
