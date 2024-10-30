local ui = require "typr.ui"
local keyboard = require "typr.ui.keys"
local state = require "typr.state"

local empty_line = {
  lines = function()
    return { {} }
  end,
  name = "kekw",
}


local border = function(id, direction)
  local icon = direction == "up" and { "┌", "┐" } or { "└", "┘" }

  return {
    lines = function()
      return {
        { { icon[1] .. string.rep("─", state.w_with_pad-2) .. icon[2], "comment" } },
      }
    end,
    name = id,
  }
end

return {

  empty_line,

  border("bline1", "up"),

  {
    lines = ui.headerbtns,
    name = "headerbtns",
  },
  border("bline1", "down"),

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
