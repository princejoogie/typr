local M = {
  ns = vim.api.nvim_create_namespace "TyprStats",
  xpad = 2,
  w = 160,
}

M.w_with_pad = M.w - (2 * M.xpad)

return M
