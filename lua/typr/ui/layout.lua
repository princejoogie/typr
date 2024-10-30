local ui = require "typr.ui"
local keyboard = require "typr.ui.keys"
local state = require "typr.state"

local empty_line = {
  lines = function()
    return { {} }
  end,
  name = "kekw",
}

return {

  empty_line,

  {
    lines = ui.words,
    name = "words",
  },

  empty_line,

  {
    lines = ui.stats,
    name = "stats",
  },
  empty_line,

  -- {
  --   lines = keyboard,
  --   name = "keyboard",
  --   xpad = function()
  --     return state.keyboard_col
  --   end,
  -- },
}
