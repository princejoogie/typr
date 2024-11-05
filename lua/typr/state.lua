local M = {
  xpad = 2,
  w = 80,
  h = 20,
  linecount = 3,
  default_lines = {},
  ui_lines = {},
  lastchar = nil,
  words_row = 4,
  timer = vim.uv.new_timer(),
  secs = 0,

  config = {
    numbers = false,
    punctuation = false,
  },

  stats = {
    accuracy = 0,
    wpm = 0,
    correct_word_ratio = "?",
  },
}

M.w_with_pad = M.w - (2 * M.xpad)

return M
