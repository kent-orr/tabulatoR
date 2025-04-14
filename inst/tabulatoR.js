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
      row: flattenData(cell.getRow().getData())
    }
  }),

  cellEdited: (cell) => ({
    cellEdited: {
      field: cell.getField(),
      value: flattenData(cell.getValue()),
      old_value: flattenData(cell.getOldValue()),
      row: flattenData(cell.getRow().getData())
    }
  }),

  validationFailed: (cell) => ({
    validationFailed: {
      field: cell.getField(),
      value: flattenData(cell.getValue()),
      old_value: flattenData(cell.getOldValue()),
      row: flattenData(cell.getRow().getData())
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
      : { [eventName]: { args } };  // fallback if user provides TRUE

    // Retrieve the current input value from Shiny
    const currentInputValue = Shiny.shinyapp.$inputValues[el.id] || {};

    // Merge the new payload with the existing input value
    const updatedInputValue = { ...currentInputValue, ...payload };

    // Send the updated input value to Shiny
    Shiny.setInputValue(el.id, updatedInputValue, { priority: "event" });
  });
});

      }
    });
  
    Shiny.outputBindings.register(tabulatoROutputBinding, "tabulatoR.output");
  })();
  