local lighten = require("volt.color").change_hex_lightness
local mix = require("volt.color").mix
local api = vim.api

local function get_hl(name)
  local hl = api.nvim_get_hl(0, { name = name })
  local result = { fg = "", bg = "" }

  if hl.fg ~= nil then
    result.fg = "#" .. ("%06x"):format(tostring(hl.fg))
  end

  if hl.bg ~= nil then
    result.bg = "#" .. ("%06x"):format(tostring(hl.bg))
  end

  return result
end

return function(ns, winType)
  local bg

  if vim.g.base46_cache then
    local colors = dofile(vim.g.base46_cache .. "colors")
    bg = colors.black
  else
    bg = get_hl("Normal").bg
  end

  bg = lighten(bg, 2)

  api.nvim_set_hl(ns, "Typrborder", { fg = bg, bg = bg })
  api.nvim_set_hl(ns, "TyprNormal", { bg = bg })

  if winType == "stats" then
    local exred = get_hl("ExRed").fg
    api.nvim_set_hl(ns, "TyprRed", { bg = mix(exred, bg, 80), fg = exred })

    local exgreen = get_hl("ExGreen").fg
    api.nvim_set_hl(ns, "TyprGreen", { bg = mix(exgreen, bg, 80), fg = exgreen })

    api.nvim_set_hl(ns, "TyprGreen0", { fg = mix(exgreen,bg, 10) })
    api.nvim_set_hl(ns, "TyprGreen1", { fg = mix(exgreen,bg, 30) })
    api.nvim_set_hl(ns, "TyprGreen2", { fg = mix(exgreen,bg, 50) })
    api.nvim_set_hl(ns, "TyprGreen3", { fg = mix(exgreen,bg, 80) })

    local exyellow = get_hl("ExYellow").fg
    api.nvim_set_hl(ns, "TyprYellow", { bg = mix(exyellow, bg, 80), fg = exyellow })

    local x = vim.o.bg == "dark" and 1 or -1
    api.nvim_set_hl(ns, "TyprGrey", { bg = lighten(bg, 6 * x), fg = lighten(get_hl("comment").fg, 10 * x) })
  end
end
