local lighten = require("volt.color").change_hex_lightness
local api = vim.api

local bg

if vim.g.base46_cache then
  local colors = dofile(vim.g.base46_cache .. "colors")
  bg = colors.black
else
  local bg_hl = api.nvim_get_hl(0, { name = "Normal" }).bg
  bg = "#" .. ("%06x"):format((bg_hl == nil and 0 or bg_hl))
end

bg = lighten(bg, 2)

api.nvim_set_hl(0, "Typrborder", { fg = bg, bg = bg })
api.nvim_set_hl(0, "TyprNormal", { bg = bg })
