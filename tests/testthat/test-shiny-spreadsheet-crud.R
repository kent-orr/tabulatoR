test_that("spreadsheet CRUD app loads successfully", {
    skip_on_cran()
    skip_if_not_installed("shinytest2")

    app <- shinytest2::AppDriver$new(
        app_dir = "apps/spreadsheet_app",
        name = "spreadsheet_crud_load",
        height = 800,
        width = 1200,
        variant = NULL
    )

    # Wait for app to load
    app$wait_for_idle()

    # Check initial status
    status_text <- app$get_text("#status")
    expect_true(grepl("Ready", status_text))

    app$stop()
})


test_that("spreadsheet can load data via proxy", {
    skip_on_cran()
    skip_if_not_installed("shinytest2")

    app <- shinytest2::AppDriver$new(
        app_dir = "apps/spreadsheet_app",
        name = "spreadsheet_load_data",
        height = 800,
        width = 1200,
        variant = NULL
    )

    app$wait_for_idle()

    # Click load data button
    app$click("load_data")
    app$wait_for_idle(500)

    # Check status updated
    status_text <- app$get_text("#status")
    expect_true(grepl("Data loaded", status_text))

    app$stop()
})


test_that("spreadsheet can clear data via proxy", {
    skip_on_cran()
    skip_if_not_installed("shinytest2")

    app <- shinytest2::AppDriver$new(
        app_dir = "apps/spreadsheet_app",
        name = "spreadsheet_clear",
        height = 800,
        width = 1200,
        variant = NULL
    )

    app$wait_for_idle()

    # Load data first
    app$click("load_data")
    app$wait_for_idle(500)

    # Then clear it
    app$click("clear_sheet")
    app$wait_for_idle(500)

    # Check status
    status_text <- app$get_text("#status")
    expect_true(grepl("Sheet cleared", status_text))

    app$stop()
})


test_that("spreadsheet can retrieve data via proxy", {
    skip_on_cran()
    skip_if_not_installed("shinytest2")

    app <- shinytest2::AppDriver$new(
        app_dir = "apps/spreadsheet_app",
        name = "spreadsheet_get_data",
        height = 800,
        width = 1200,
        variant = NULL
    )

    app$wait_for_idle()

    # Load data
    app$click("load_data")
    app$wait_for_idle(500)

    # Get data
    app$click("get_data")
    app$wait_for_idle(500)

    # Check that data was retrieved
    data_text <- app$get_text("#current_data")
    expect_true(grepl("Retrieved data", data_text))

    app$stop()
})


test_that("spreadsheet CRUD operations work in sequence", {
    skip_on_cran()
    skip_if_not_installed("shinytest2")

    app <- shinytest2::AppDriver$new(
        app_dir = "apps/spreadsheet_app",
        name = "spreadsheet_crud_sequence",
        height = 800,
        width = 1200,
        variant = NULL
    )

    app$wait_for_idle()

    # 1. Load data
    app$click("load_data")
    app$wait_for_idle(500)
    expect_true(grepl("Data loaded", app$get_text("#status")))

    # 2. Get data
    app$click("get_data")
    app$wait_for_idle(500)
    expect_true(grepl("Retrieved data", app$get_text("#current_data")))

    # 3. Clear sheet
    app$click("clear_sheet")
    app$wait_for_idle(500)
    expect_true(grepl("Sheet cleared", app$get_text("#status")))

    # 4. Load data again
    app$click("load_data")
    app$wait_for_idle(500)
    expect_true(grepl("Data loaded", app$get_text("#status")))

    app$stop()
})
