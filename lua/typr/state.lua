local M = {
  xpad = 2,
  w = 80,
  h = 20,
  linecount = 3,
  default_lines = {},
  ui_lines = {},
  lastchar = nil,
  words_row = 5,
  timer = vim.uv.new_timer(),
  secs = 0,

  addons = {
    numbers = false,
    punctuation = false,
    time = 30,
  },

  stats = {
    wordcount = 0,
    accuracy = 0,
  },
}

M.w_with_pad = M.w - (2 * M.xpad)

return M
