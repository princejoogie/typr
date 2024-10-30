local M = {
  xpad = 2,
  w = math.floor(vim.o.columns / 2),
  h = 20,
  linecount = 3,
  default_lines = {},
  ui_lines = {},
  lastchar = "",

  stats = {
    wordcount = 0,
    accuracy = 0,
  },
}

M.w_with_pad = M.w + (2 * M.xpad)

return M
