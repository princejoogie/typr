local ui = require "typr.stats.ui"
local state = require "typr.state"

local empty_line = {
  lines = function()
    return { {} }
  end,
  name = "emptyline",
}

local border = function(id, direction)
  local icon = direction == "up" and { "┌", "┐" } or { "└", "┘" }

  return {
    lines = function()
      return {
        { { icon[1] .. string.rep("─", state.w_with_pad - 2) .. icon[2], "comment" } },
      }
    end,
    name = id,
  }
end

return {

  -- border("bline1", "up"),

  empty_line,

  {
    lines = ui.chadstack,
    name = "stats",
  },

  empty_line,

  {
    lines = function()
      return {
        { { "                          History of Last 5 tests :" } },
      }
    end,
    name = "History label",
  },

  {
    lines = ui.history,
    name = "history",
  },

  -- border("bline1", "down"),
}
