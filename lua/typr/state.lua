local M = {
  xpad = 2,
  w = 80,
  h = 20,
  linecount = 3,
  default_lines = {},
  ui_lines = {},
  lastchar = "",

  addons = {
    numbers = false,
    punctuation = false,
    time = 15,
  },

  stats = {
    wordcount = 0,
    accuracy = 0,
  },
}

M.w_with_pad = M.w - (2 * M.xpad)

return M
