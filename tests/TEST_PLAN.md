# tabulatoR Test Plan

## Overview
This document outlines the testing strategy for the tabulatoR package, organized by functional area with clear separation of concerns.

## Test Organization

### 1. Core Rendering (`test-render.R`)
**Purpose**: Test the basic table rendering pipeline and JSON serialization

**Test Cases**:
- [ ] Basic table with simple data.frame
  - Simple data types (numeric, character, logical)
  - Different data sizes (empty, single row, multiple rows)
- [ ] Auto-generated columns
  - Column names match data.frame names
  - Default editor settings based on editable flag
- [ ] Custom layout options
  - Different layout modes (fitColumns, fitData, etc.)
- [ ] JSON output structure
  - Correct payload shape (options, data, events)
  - Data serialization as array of row objects
  - Proper unboxing of scalar values
- [ ] Column flattening
  - Handle c() syntax
  - Handle list() syntax
  - Handle mixed nested lists
  - Preserve unnamed structure for JSON arrays

### 2. JavaScript Integration (`test-js.R`)
**Purpose**: Test JavaScript code embedding and serialization

**Test Cases**:
- [ ] JS() function behavior
  - Creates proper class structure (JS_EVAL)
  - Accepts character strings only
  - Error handling for invalid input
- [ ] Serialization through htmlwidgets::toJSON2
  - JS objects serialize as strings (not arrays)
  - Special markers for client-side detection
  - Nested JS in complex structures
- [ ] Backwards compatibility
  - js() as alias for JS()
  - Existing code continues to work
- [ ] Client-side evaluation (integration test)
  - JavaScript code is properly unwrapped
  - Functions are callable on client side
  - Error handling for invalid JS code

### 3. Column Definitions (`test-columns.R`)
**Purpose**: Test column definition helpers

**Test Cases**:
- [ ] Column() basic structure
  - Required fields (title, field)
  - Optional fields (visible, hozAlign, width, etc.)
  - Returns properly shaped list
- [ ] Column() editor behavior
  - editor parameter enables editing
  - editable=TRUE with no editor sets editor=TRUE
  - Explicit editable=FALSE prevents editing
- [ ] Column() with JS callbacks
  - formatter with JS()
  - cellClick with JS()
  - cellEdited with JS()
  - editor as JS function
- [ ] ActionColumn() structure
  - Generates valid formatter function
  - Button label rendering
  - Icon integration
  - Event payload structure
  - Custom CSS classes
- [ ] Column composition
  - Using .opts for reusable configs
  - ... parameters override .opts
  - Combining multiple option sources

### 4. Output Binding (`test-output.R`)
**Purpose**: Test the HTML widget output generation

**Test Cases**:
- [ ] tabulatoROutput() creates correct HTML
  - Proper div structure
  - Correct ID assignment
  - Width and height attributes
  - CSS class assignment
- [ ] Dependency inclusion
  - Tabulator CSS loaded
  - Tabulator JS loaded
  - Package JS loaded
  - Correct order of dependencies

### 5. Proxy Operations (`test-proxy.R`)
**Purpose**: Test server-to-client table updates

**Test Cases**:
- [ ] tabulatorReplaceData()
  - Sends correct message type
  - Properly serializes data.frame
  - Includes correct table ID
- [ ] tabulatorAddData()
  - Add to top
  - Add to bottom
  - Proper data serialization
- [ ] tabulatorRemoveRow()
  - Correct index targeting
  - Message structure
- [ ] tabulatorRestoreOldValue()
  - Correct field and index
  - Message structure

### 6. Events (`test-events.R`)
**Purpose**: Test event handler configuration and integration

**Test Cases**:
- [ ] Default event handlers exist
  - cellClick, cellEdited, validationFailed
  - rowAdded, rowDeleted
- [ ] Custom event handlers
  - Can override defaults
  - Custom events with JS()
  - Event payload structure
- [ ] Event serialization
  - Custom events in renderTabulatoR
  - Events serialize with JS markers
  - Client-side merging of default and custom

### 7. CRUD Operations (`test-crud.R`)
**Purpose**: Test interactive editing workflows

**Test Cases**:
- [ ] Cell editing
  - Edit triggers event
  - Data updates properly
  - Validation handling
- [ ] Row operations
  - Add row
  - Delete row
  - Row selection
- [ ] Integration with Shiny inputs
  - Events create reactive inputs
  - Input structure matches expected format

### 8. Preview Functions (`test-preview-static.R`, `test-preview-crud.R`)
**Purpose**: Test standalone table preview outside Shiny

**Test Cases**:
- [ ] Static preview
  - Basic data.frame display
  - Column configurations
  - No Shiny dependencies
- [ ] CRUD preview
  - Interactive editing enabled
  - Event handlers work
  - Self-contained app

### 9. Integration Tests (`test-app.R`)
**Purpose**: Full end-to-end testing with running Shiny apps

**Test Cases**:
- [ ] Basic table rendering in app
- [ ] User interactions
- [ ] Data updates via proxy
- [ ] Custom formatters and editors
- [ ] Event handling roundtrip

## Test Utilities

### Helper Functions
```r
# Snapshot JSON for readable diffs
expect_snapshot_json <- function(x) {
  testthat::expect_snapshot(jsonlite::prettify(x))
}

# Create mock Shiny session
mock_session <- function() {
  shiny::MockShinySession$new()
}

# Test JS serialization roundtrip
expect_js_serializes <- function(obj, pattern) {
  json <- htmlwidgets:::toJSON2(obj, auto_unbox = TRUE)
  expect_match(json, pattern)
}
```

## Current Status

### Existing Tests (to review/refactor)
- ✅ `test-render.R` - Basic rendering and column flattening
- ✅ `test-output.R` - Output binding HTML generation
- ✅ `test-columns.R` - ActionColumn snapshots
- ✅ `test-events.R` - Event handler configuration
- ✅ `test-proxy.R` - Proxy operations
- ✅ `test-crud.R` - CRUD workflows
- ✅ `test-preview-static.R` - Static preview
- ✅ `test-preview-crud.R` - CRUD preview
- ✅ `test-app.R` - App integration

### New Tests Needed
- 🔨 `test-js.R` - JavaScript handling (IN PROGRESS)
  - Need to implement JS() function first
  - Need to define expected behavior
  - Need serialization tests

## Priority Order

1. **IMMEDIATE**: Define and test basic table rendering
   - Ensure core functionality works
   - Establish baseline behavior

2. **HIGH**: JavaScript integration (JS/js functions)
   - Critical for user experience
   - Needs to match htmlwidgets expectations

3. **MEDIUM**: Column definitions
   - Already partially tested
   - Needs expansion for edge cases

4. **LOW**: Proxy and events
   - Already well tested
   - May need cleanup/refactoring

## Notes
- Focus on unit tests first (isolated functionality)
- Integration tests should be minimal but comprehensive
- Snapshot tests for complex output structures
- Mock Shiny sessions for all rendering tests
