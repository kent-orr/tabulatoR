/**
 * Parses and evaluates JavaScript code embedded in string values
 * 
 * This function looks for strings wrapped in <js> tags and evaluates them as JavaScript code.
 * It's used to allow R code to pass executable JavaScript functions to the browser through
 * JSON serialization, which normally doesn't support functions.
 * 
 * Example:
 * "<js>function(cell) { return cell.getValue() * 2; }</js>" becomes a callable JavaScript function
 * 
 * @param {*} val - The value to check and potentially parse
 * @returns {*} Either the original value or the evaluated JavaScript if it was wrapped in <js> tags
 */
function parseJSValue(val) {
    const startTag = '<js>';
    const endTag = '</js>';

    if (typeof val === 'string' && val.startsWith(startTag) && val.endsWith(endTag)) {
        const body = val.slice(startTag.length, -endTag.length);
        try {
            return eval(`(${body})`); // Make it a callable function
        } catch (e) {
            console.warn("Failed to evaluate <js> string:", body, e);
            return null; 
        }
    }

    return val;
}

/**
 * Recursively processes an object tree to evaluate any embedded JavaScript
 * 
 * This function traverses through arrays and objects, applying parseJSValue to each
 * leaf value. It's used to process configuration objects coming from R, allowing
 * JavaScript functions to be embedded at any level of the object hierarchy.
 * 
 * The function preserves the structure of the input object while transforming
 * any <js>-tagged strings into executable JavaScript functions.
 * 
 * @param {*} obj - The object to process
 * @returns {*} A new object with the same structure but with JavaScript strings evaluated
 */
function recursivelyUnwrapJS(obj) {
    if (Array.isArray(obj)) {
        return obj.map(recursivelyUnwrapJS);
    } else if (obj !== null && typeof obj === 'object') {
        const out = {};
        for (const key in obj) {
            out[key] = recursivelyUnwrapJS(obj[key]);
        }
        return out;
    } else {
        return parseJSValue(obj);
    }
}



/**
 * Recursively flattens and simplifies data structures for Shiny communication
 * 
 * This function performs two main operations:
 * 1. Unwraps single-item arrays (e.g., [42] becomes 42)
 * 2. Recursively processes nested objects and arrays
 * 
 * The function is designed to simplify complex data structures before sending them
 * to Shiny, making them easier to work with in R. It's particularly useful for
 * handling Tabulator's nested data structures and ensuring they're properly
 * formatted for R consumption.
 * 
 * @param {*} data - The data to flatten, can be any JavaScript value
 * @returns {*} A simplified version of the input data with single-item arrays unwrapped
 */
function flattenData(data) {
        if (Array.isArray(data) && data.length === 1) {
                return flattenData(data[0]); // Unwrap single-item arrays
        } else if (typeof data === 'object' && data !== null) {
                const out = {};
                for (const key in data) {
                        out[key] = flattenData(data[key]); // Recursively flatten each property
                }
                return out;
        }
        return data; // Return the value as is if it's not an array or object
}

/**
 * Default event handlers for Tabulator events
 * These functions process Tabulator events and format them for Shiny input values
 * Each handler returns an object with a consistent structure including an 'action' field
 * that identifies the event type
 */
const defaultEventHandlers = {
        /**
         * Handles cell click events
         * @param {Event} e - The browser click event
         * @param {Cell} cell - The Tabulator cell component that was clicked
         * @returns {Object} Formatted data about the clicked cell including field, value, and row data
         */
        cellClick: (e, cell) => ({
                action: 'cellClick',
                field: cell.getField(),
                value: flattenData(cell.getValue()),
                row: flattenData(cell.getRow().getData()),
                index: flattenData(cell.getRow().getPosition())
        }),
        
        /**
         * Handles cell edit events
         * @param {Cell} cell - The Tabulator cell component that was edited
         * @returns {Object} Formatted data about the edited cell including field, new value, old value, and row data
         */
        cellEdited: (cell) => ({
                action: 'cellEdited',
                field: cell.getField(),
                value: flattenData(cell.getValue()),
                old_value: flattenData(cell.getOldValue()),
                row: flattenData(cell.getRow().getData()),
                index: flattenData(cell.getRow().getPosition())
        }),
        
        /**
         * Handles validation failure events
         * @param {Cell} cell - The Tabulator cell component that failed validation
         * @returns {Object} Formatted data about the validation failure including field, attempted value, and row data
         */
        validationFailed: (cell) => ({
                action: 'validationFailed',
                field: cell.getField(),
                value: flattenData(cell.getValue()),
                old_value: flattenData(cell.getOldValue()),
                row: flattenData(cell.getRow().getData()),
                index: flattenData(cell.getRow().getPosition())
        }),
        
        /**
         * Handles row addition events
         * @param {Row} row - The Tabulator row component that was added
         * @returns {Object} Formatted data about the added row
         */
        rowAdded: (row) => ({
                action: 'rowAdded',
                row: flattenData(row.getData())
        }),
        
        /**
         * Handles row deletion events
         * @param {Row} row - The Tabulator row component that was deleted
         * @returns {Object} Formatted data about the deleted row
         */
        rowDeleted: (row) => ({
                action: 'rowDeleted',
                row: flattenData(row.getData())
        })
};

(function() {
    const tabulatoROutputBinding = new Shiny.OutputBinding();

    $.extend(tabulatoROutputBinding, {
        find: function(scope) {
            return $(scope).find(".tabulator-output");
        },

        renderValue: function(el, payload) {
            if (!payload) return;

            const debug = payload.options?.debug;

            // Reuse or initialize table
            if (el._tabulator) {
                if (debug) {
                    console.log("Updating Tabulator data");
                }
                el._tabulator.replaceData(payload.options?.data || []);
                return;
            }

            let options = payload.options || {};
            options = recursivelyUnwrapJS(options);

            if (options.debug) {
                console.log("Initializing Tabulator with options:", options);
            }
            const table = new Tabulator(el, options);

            el._tabulator = table;

            // attach the table to a global var
            window[el.id] = table;
            
            // Attach event listeners to Tabulator events

            // Default events if none were provided
            const userEvents = payload.events || {};
            const mergedEvents = { ...defaultEventHandlers, ...userEvents };

            Object.keys(mergedEvents).forEach(eventName => {
                const handler = mergedEvents[eventName];

                table.on(eventName, (...args) => {
                    if (options.debug) {
                        console.log(`📥 Tabulator event: ${eventName}`, args);
                    }

                    // Run user-defined or default extractor
                    const payload = typeof handler === "function"
                    ? handler(...args)
                    : { [eventName]: { args } };
                    
                    // Explicitly set only the latest event (no merge!)
                    Shiny.setInputValue(el.id, payload, { priority: "event" });
                });
            });


            // proxy functions
            Shiny.addCustomMessageHandler('tabulator-replace-data', function(message) {
                if (message.id === el.id) {
                    if (options.debug) {
                        console.log('Received tabulator-replace-data message:', message);
                    }
                    el._tabulator.replaceData(message.data);
                }
            });

            Shiny.addCustomMessageHandler('tabulator-add-data', function(message) {
                if (message.id === el.id) {
                    if (options.debug) {
                        console.log('Received tabulator-add-data message:', message);
                    }
                    el._tabulator.addData(message.data, message.add_to);
                }
            });

            Shiny.addCustomMessageHandler('tabulator-remove-data', function(message) {
                if (message.id === el.id) {
                    if (options.debug) {
                        console.log('Received tabulator-remove-data message:', message);
                    }
                    el._tabulator.removeData(message.index);
                }
            });

            Shiny.addCustomMessageHandler('tabulator-revert-field', function(message) {
                if (message.id === el.id) {
                    if (options.debug) {
                        console.log('Received tabulator-revert-field message:', message);
                    }
                    const row = el._tabulator.getRow(message.index);
                    const cell = row.getCell(message.field);
                    cell.restoreOldValue();
                }
            });
            
        }
    });
    
    Shiny.outputBindings.register(tabulatoROutputBinding, "tabulatoR.output");
})();
