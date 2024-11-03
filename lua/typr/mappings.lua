local state = require "typr.state"
local map = vim.keymap.set
local api = vim.api

map("i", "<Space>", function()
  local pos = vim.api.nvim_win_get_cursor(state.win)
  local curline_end = #state.default_lines[pos[1] - state.words_row]

  if pos[2] > curline_end then
    if state.words_row_end == pos[1] then
      state.timer:stop()
      vim.cmd.stopinsert()
      return
    end

    api.nvim_win_set_cursor(state.win, { pos[1] + 1, 2 })
  else
    api.nvim_feedkeys(" ", "n", true)
  end
end, { buffer = state.buf })

map("n", "i", function()
  api.nvim_win_set_cursor(state.win, { state.words_row + 1, 2 })
  vim.cmd.startinsert()
end, { buffer = state.buf })
