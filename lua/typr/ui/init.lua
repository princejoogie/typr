local M = {}
local state = require "typr.state"
local volt = require "volt"
local api = require("typr.api")

M.words = function()
  return state.ui_lines
end

local k = { string.rep(" ", 24) }
M.headerbtns = function()
  local hovermark = vim.g.nvmark_hovered
  local addons = state.addons

  local puncbtn = {
    "  Punctuation ",
    (addons.punctuation or hovermark == "punc_m") and "exgreen" or "comment",

    {
      hover = { id = "punc_m", redraw = "headerbtns" },
      click = api.toggle_punctuation,
    },
  }

  local numbtn = {
    "   Numbers ",
    (addons.numbers or hovermark == "num_m") and "exgreen" or "comment",

    {
      hover = { id = "num_m", redraw = "headerbtns" },
      click = api.toggle_numbers,
    },
  }

  local timebtn = { "  Time ", "exred" }

  local timeaction = function(x)
    -- hover = { id = "time_m", redraw = "headerbtns" },
    return function()
      state.addons.time = x
      volt.redraw(state.buf, "headerbtns")
    end
  end

  return {
    {
      { "│ ", "comment" },
      puncbtn,
      numbtn,
      k,
      timebtn,

      { " 15 *", addons.time == 15 and "" or "comment", timeaction(15) },
      { " 30 *", addons.time == 30 and "" or "comment", timeaction(30) },
      { " 60", addons.time == 60 and "" or "comment", timeaction(60) },
      { " │", "comment" },
    },
  }
end

M.stats = function()
  return {
    {
      { " WPM ", "lazyh1" },
      { " " .. state.stats.wordcount .. " ", "visual" },
      { "    Accuracy: " .. state.stats.accuracy .. " % " },
    },
  }
end

return M
