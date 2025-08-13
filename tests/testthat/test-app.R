library(shinytest2)

app <- AppDriver$new(
    app_dir = testthat::test_path(".."),
    name = "app",
    variant = platform_variant(),
    seed = 123
)

app$wait_for_js("window.table !== undefined")

app$run_js("window.table.getRows()[0].getCell('mpg').setValue(99);")
app$wait_for_value(input = "table")
app$expect_values(input = "table", screenshot = FALSE)

app$run_js("window.table.addData([{id: 1000, mpg: 30, cyl: 4}]);")
app$wait_for_value(input = "table")
app$expect_values(input = "table", screenshot = FALSE)

app$run_js("window.table.getRows()[0].delete();")
app$wait_for_value(input = "table")
app$expect_values(input = "table", screenshot = FALSE)
