(function() {
    const tabulatoROutputBinding = new Shiny.OutputBinding();
  
    console.log("tabulatoR output binding registered");
  
    $.extend(tabulatoROutputBinding, {
      find: function(scope) {
        return $(scope).find(".tabulator-output");
      },
  
      renderValue: function(el, payload) {
        if (!payload) return;
  
        // Reuse or initialize table
        if (el._tabulator) {
          console.log("Updating Tabulator data");
          el._tabulator.replaceData(payload.options?.data || []);
          return;
        }
  
        const options = payload.options || {};
        console.log("🆕 Initializing Tabulator with options:", options);
        const table = new Tabulator(el, options);
        el._tabulator = table;
  
        const events = payload.events || {};
        Object.keys(events).forEach(event => {
          table.on(event, (...args) => {
            console.log(`Tabulator event: ${event}`, args);
            Shiny.setInputValue(`${el.id}_${event}`, args, { priority: "event" });
          });
        });
      }
    });
  
    Shiny.outputBindings.register(tabulatoROutputBinding, "tabulatoR.output");
  })();
  