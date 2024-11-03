local M = {}
local state = require "typr.state"
local volt = require "volt"
local api = require "typr.api"
local myapi = require "typr.api"

M.words = function()
  return state.ui_lines
end

local spaces = { string.rep(" ", 26) }

M.headerbtns = function()
  local hovermark = vim.g.nvmark_hovered
  local addons = state.addons

  local puncbtn = {
    "  Punctuation ",
    (addons.punctuation or hovermark == "punc_m") and "exgreen" or "normal",

    {
      hover = { id = "punc_m", redraw = "headerbtns" },
      click = api.toggle_punctuation,
    },
  }

  local numbtn = {
    "   Numbers ",
    (addons.numbers or hovermark == "num_m") and "exgreen" or "normal",

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

local border = function(direction)
  local icon = direction == "up" and { "┌", "┐" } or { "└", "┘" }

  return { {
    icon[1] .. string.rep("─", state.w_with_pad - 2) .. icon[2],
    "added",
  } }
end

M.stats = function()
  local stats = state.stats

  vim.print(stats.wpm)

  if state.secs == 0 then
    return { {}, {} }
  end

  if stats.wpm == 0 then
    return {
      { { string.rep(" ", (state.w_with_pad / 2) - 3) }, { "  " .. state.secs .. "s  " } },
    }
  end

  local txts = {
    { "│ ", "added" },
    { "Results:", "Added" },
    { "  Words : " .. stats.correct_word_ratio },
    { "    Accuracy: " .. stats.accuracy .. "%" },
    { "    " .. state.secs .. "s  " },
    { " WPM ", "pmenusel" },
    { " " .. stats.wpm .. " ", "visual" },
    { " │", "added" },
  }

  local totalstrlen = 0

  for _, v in ipairs(txts) do
    totalstrlen = totalstrlen + #v[1]
  end

  table.insert(txts, #txts, { string.rep(" ", state.w - totalstrlen + 4), "added" })

  return {
    border "up",
    txts,
    border "down",
    {},
  }
end

M.mappings = function()
  return {
    {
      { " ESC ", "visual" },
      { " or ", "comment" },
      { " q ", "visual" },
      { " - Quit ", "comment" },

      { "  " },

      { " i ", "visual" },
      { " - Start ", "comment" },

      { "                   " },

      { " CTRL ", "visual" },
      { " " },
      { " R ", "visual" },
      { " - Restart ", "comment" },
    },
  }
end

return M
