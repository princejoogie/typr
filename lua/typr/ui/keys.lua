local state = require "typr.state"

local keys = {
  -- { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
  { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
  { "a", "s", "d", "f", "g", "h", "j", "k", "l" },
  { "z", "x", "c", "v", "b", "n", "m" },
}

local function gen_keyboard()
  local lines = {}

  for i, v in ipairs(keys) do
    local line = {}


    i = i == 3 and  6 or i
    table.insert(line, {string.rep(" ", i) })

    for _, char in ipairs(v) do
      local active_hl = char == state.lastchar and "lazyh1" or "Visual"
      -- borders
      table.insert(line, { " " .. char .. " ", active_hl })
      table.insert(line, { " " })
    end

    table.insert(lines, line)
    table.insert(lines, {})
  end

  local active_hl = " " == state.lastchar and "lazyh1" or "Visual"

  table.insert(lines, { {"             "},  { "     󱁐     ", active_hl } })

  return lines
end

return gen_keyboard
