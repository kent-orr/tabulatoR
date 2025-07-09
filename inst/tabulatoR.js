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

const defaultEventHandlers = {
    cellClick: (e, cell) => ({
        cellClick: {
            field: cell.getField(),
            value: flattenData(cell.getValue()),
            row: flattenData(cell.getRow().getData()),
            index: flattenData(cell.getRow().getPosition())
        }
    }),
    
    cellEdited: (cell) => ({
        cellEdited: {
            field: cell.getField(),
            value: flattenData(cell.getValue()),
            old_value: flattenData(cell.getOldValue()),
            row: flattenData(cell.getRow().getData()),
            index: flattenData(cell.getRow().getPosition())
        }
    }),
    
    validationFailed: (cell) => ({
        validationFailed: {
            field: cell.getField(),
            value: flattenData(cell.getValue()),
            old_value: flattenData(cell.getOldValue()),
            row: flattenData(cell.getRow().getData()),
            index: flattenData(cell.getRow().getPosition())
        }
    }),
    
    rowAdded: (row) => ({
        rowAdded: {
            row: flattenData(row.getData())
        }
    }),
    
    rowDeleted: (row) => ({
        rowDeleted: {
            row: flattenData(row.getData())
        }
    })
};

(function() {
    const tabulatoROutputBinding = new Shiny.OutputBinding();
    
    console.log("output binding created");
    
    $.extend(tabulatoROutputBinding, {
        find: function(scope) {
            return $(scope).find(".tabulator-output");
        },
        
        renderValue: function(el, payload) {
            console.log('payload?');
            if (!payload) return;
            
            // Reuse or initialize table
            if (el._tabulator) {
                console.log("Updating Tabulator data");
                el._tabulator.replaceData(payload.options?.data || []);
                return;
            }
            
            const options = payload.options || {};
            console.log("Initializing Tabulator with options:", options);
            const table = new Tabulator(el, options);
            el._tabulator = table;

            // attach the table to a global var
            window[el.id] = table;
            
            // Attach event listeners to Tabulator events
            const inputId = el.id;
            
            const eventCache = {};
            
            // Default events if none were provided
            const userEvents = payload.events || {};
            const mergedEvents = { ...defaultEventHandlers, ...userEvents };
            
            Object.keys(mergedEvents).forEach(eventName => {
                const handler = mergedEvents[eventName];

                table.on(eventName, (...args) => {
                    console.log(`📥 Tabulator event: ${eventName}`, args);
                    
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
                    console.log('Received tabulator-replace-data message:', message);
                    el._tabulator.replaceData(message.data);
                }
            });

            Shiny.addCustomMessageHandler('tabulator-add-data', function(message) {
                if (message.id === el.id) {
                    console.log('Received tabulator-add-data message:', message);
                    el._tabulator.addData(message.data, message.add_to);
                }
            });

            Shiny.addCustomMessageHandler('tabulator-remove-data', function(message) {
                if (message.id === el.id) {
                    console.log('Received tabulator-remove-data message:', message);
                    el._tabulator.removeData(message.index);
                }
            });
            
        }
    });
    
    Shiny.outputBindings.register(tabulatoROutputBinding, "tabulatoR.output");
})();
