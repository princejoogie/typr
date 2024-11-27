local ui = require "typr.stats.ui"

local empty_line = {
  lines = function()
    return { {} }
  end,
  name = "emptyline",
}

return {

  empty_line,

  {
    lines = ui.progress,
    name = "progress",
  },

  empty_line,

  {
    lines = ui.tabular_stats,
    name = "tabular_stats",
  },

  empty_line,
  {
    lines = ui.graph,
    name = "graph",
  },


  empty_line,
  {
    lines = ui.keys_accuracy,
    name = "keys_accuracy",
  },
  

  -- {
  --   lines = ui.rawpm,
  --   name = "rawpm",
  -- },
}
