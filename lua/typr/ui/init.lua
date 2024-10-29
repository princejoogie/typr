local M = {}
local state = require "typr.state"

M.words = function()
  return state.ui_lines
end

M.stats = function()
  return {
    {
      { " WPM " , "lazyh1"  },
      { " " ..state.stats.wordcount .. " ", "visual" },
      { "    Accuracy: " .. state.stats.accuracy .. " % "},
    },
  }
end

return M
