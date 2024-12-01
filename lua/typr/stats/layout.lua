local ui = require "typr.stats.ui"
local volt_ui = require "volt.ui"
local state = require "typr.state"

local empty_line = {
  lines = function()
    return { {} }
  end,
  name = "emptyline",
}

local leftcol_ui = function()
  return volt_ui.grid_row {
    ui.progress(),
    { {} },
    ui.tabular_stats(),
    { {} },
    ui.graph(),
    { {} },
    ui.rawpm(),
  }
end

local rightcol_ui = function()
  return volt_ui.grid_row {
    ui.keys_accuracy(),
    { {} },
    ui.char_times(),
  }
end

local divider = function()
  local result = {}

  for _ = 1, state.h do
    table.insert(result, { { "  │  ", "linenr" } })
  end

  return result
end

return {

  empty_line,

  {
    lines = function()
      return volt_ui.grid_col {
        {
          lines = leftcol_ui(),
          w = state.w_with_pad,
          pad = 1,
        },

        {
          lines = divider(),
          w = 1,
        },

        {
          lines = rightcol_ui(),
          w = state.w_with_pad,
        },
      }
    end,
    name = "typrStats",
  },
}
