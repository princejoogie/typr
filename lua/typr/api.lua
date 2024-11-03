local M = {}
local volt = require "volt"
local state = require "typr.state"
local utils = require "typr.utils"

M.toggle_punctuation = function()
  state.addons.punctuation = not state.addons.punctuation
  volt.redraw(state.buf, "headerbtns")
  vim.print { state.addons.punctuation }
end

M.toggle_numbers = function()
  state.addons.numbers = not state.addons.numbers
  volt.redraw(state.buf, "headerbtns")
  print "bruh"
end

M.set_linecount = function(x)
  local diff = x - state.linecount 
  state.linecount = x
  state.h = state.h + diff
  utils.gen_default_lines()
  utils.set_emptylines()
  vim.api.nvim_win_set_height(state.win, state.h)

  require('typr').initialize_volt()

  volt.redraw(state.buf, "all")
end

return M
