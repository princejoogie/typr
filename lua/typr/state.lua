local M = {
  ns=vim.api.nvim_create_namespace "Typr",
  xpad = 2,
  w = 80,
  h = 20,
  linecount = 1,
  default_lines = {},
  ui_lines = {},
  lastchar = nil,
  words_row = 4,
  timer = vim.uv.new_timer(),
  secs = 0,

  config = {
    wpm_goal = 200,
    numbers = false,
    punctuation = false,
    random = false,
    stats_filepath = vim.fn.stdpath "config" .. "/typrstats",
  },

  stats = {
    accuracy = 0,
    wpm = 0,
    correct_word_ratio = "?",
    total_char_count = 0,
    typed_char_count = 0,
  },

  stats_history = {},
}

M.w_with_pad = M.w - (2 * M.xpad)

return M
