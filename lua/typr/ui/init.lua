local M = {}
local state = require "typr.state"
local volt = require "volt"
local api = require "typr.api"

M.words = function()
  return state.ui_lines
end

local spaces = { string.rep(" ", 15) }

M.headerbtns = function()
  local hovermark = vim.g.nvmark_hovered
  local config = state.config

  local puncbtn = {
    "  Punctuation ",
    (config.punctuation or hovermark == "punc_m") and "exgreen" or "normal",

    {
      hover = { id = "punc_m", redraw = "headerbtns" },
      click = api.toggle_punctuation,
    },
  }

  local numbtn = {
    "   Numbers ",
    (config.numbers or hovermark == "num_m") and "exgreen" or "normal",

    {
      hover = { id = "num_m", redraw = "headerbtns" },
      click = api.toggle_numbers,
    },
  }

  local randombtn = {
    "   Random ",
    (config.random or hovermark == "random_m") and "exgreen" or "normal",

    {
      hover = { id = "random_m", redraw = "headerbtns" },
      click = api.random_words,
    },
  }

  local linesbtn = { "  Lines ", "exred" }

  local setline = function(x)
    -- hover = { id = "time_m", redraw = "headerbtns" },
    return function()
      volt.redraw(state.buf, "headerbtns")
      api.set_linecount(x)
    end
  end

  return {
    {
      { "│ ", "commentfg" },
      puncbtn,
      numbtn,
      randombtn,
      spaces,
      linesbtn,

      { " 3 *", state.linecount == 3 and "" or "commentfg", setline(3) },
      { " 6 *", state.linecount == 6 and "" or "commentfg", setline(6) },
      { " 9", state.linecount == 9 and "" or "commentfg", setline(9) },
      { " │", "commentfg" },
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
    totalstrlen = totalstrlen + vim.api.nvim_strwidth(v[1])
  end

  table.insert(txts, #txts - 2, { string.rep(" ", state.w_with_pad - totalstrlen), "added" })

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
      { " or ", "commentfg" },
      { " q ", "visual" },
      { " - Quit ", "commentfg" },

      { "  " },

      { " i ", "visual" },
      { " - Start ", "commentfg" },

      { "                   " },

      { " CTRL ", "visual" },
      { " " },
      { " R ", "visual" },
      { " - Restart ", "commentfg" },
    },
  }
end

return M
