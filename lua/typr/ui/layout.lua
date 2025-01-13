local ui = require "typr.ui"
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
        { { icon[1] .. string.rep("─", state.w_with_pad - 2) .. icon[2], "commentfg" } },
      }
    end,
    name = id,
  }
end

return {

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

  {
    lines = ui.mappings,
    name = "mappings",
  },
}
