local M = {}
local state = require "typr.state"
local volt = require "volt"
local api = require("typr.api")
local myapi = require("typr.api")

M.words = function()
  return state.ui_lines
end

local spaces = { string.rep(" ", 26) }

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

  local linesbtn = { "  Lines ", "exred" }

  local setline = function(x)
    -- hover = { id = "time_m", redraw = "headerbtns" },
    return function()
      volt.redraw(state.buf, "headerbtns")
      myapi.set_linecount(x)
    end
  end

  return {
    {
      { "│ ", "comment" },
      puncbtn,
      numbtn,
      spaces,
      linesbtn,

      { " 3 *", state.linecount == 3 and "" or "comment", setline(3) },
      { " 6 *", state.linecount == 6 and "" or "comment", setline(6) },
      { " 9", state.linecount == 9 and "" or "comment", setline(9) },
      { " │", "comment" },
    },
  }
end

M.stats = function()
  local stats = state.stats
  return {
    {
      { " WPM ", "lazyh1" },
      { " " .. stats.wpm .. " ", "visual" },
      {"  Words Typed: " .. stats.correct_word_ratio},
      { "    Accuracy: " .. stats.accuracy .. " %" },
      { "    " .. state.secs .. "s"},
    },
  }
end

return M
