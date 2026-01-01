# Generate Tabulator Source Links

This function generates the necessary HTML tags to include Tabulator's
CSS and JavaScript files. cdn for versions and css can be found at
https://app.unpkg.com/tabulator-tables

## Usage

``` r
tab_source(version = "6.3.1", theme = "tabulator_bootstrap5")
```

## Arguments

- version:

  A character string specifying the version of Tabulator to use.
  Defaults to "6.3.1".

- theme:

  A character string specifying the theme to use. Defaults to
  "tabulator_bootstrap5".

## Value

A `tagList` containing the HTML tags for the Tabulator CSS and
JavaScript files.

## Examples

``` r
tab_source()
#> Error in tab_source(): could not find function "tab_source"
tab_source(version = "5.0", theme = "tabulator_simple")
#> Error in tab_source(version = "5.0", theme = "tabulator_simple"): could not find function "tab_source"
```
