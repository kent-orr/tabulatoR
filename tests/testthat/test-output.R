library(tabulatoR)

test_that("tabulatoROutput creates a div with correct attributes and dependencies", {
  tag <- tabulatoROutput("test-id", width = "50%", height = "300px")
  div <- tag[[2]]
  expect_equal(div$name, "div")
  expect_equal(div$attribs$id, "test-id")
  expect_equal(div$attribs$width, "50%")
  expect_equal(div$attribs$height, "300px")
  expect_true("tabulator-output" %in% div$attribs$class)

  rendered <- htmltools::renderTags(tag)$head
  expect_true(grepl("tabulator.min.css", rendered))
  expect_true(grepl("tabulator.min.js", rendered))
})
