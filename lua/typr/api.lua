local M = {}
local volt = require "volt"
local state = require "typr.state"

M.toggle_punctuation = function()
  state.addons.punctuation = not state.addons.punctuation
  volt.redraw(state.buf, "headerbtns")
  vim.print{state.addons.punctuation}
end

M.toggle_numbers = function()
  state.addons.numbers = not state.addons.numbers
  volt.redraw(state.buf, "headerbtns")
  print('bruh')
end

return M
