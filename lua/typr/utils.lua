local M = {}
local state = require "typr.state"
local words = require "typr.words"

M.words_to_lines = function()
  local lines = {}
  local maxw = (state.w_with_pad ) - 7

  for _ = 1, state.linecount do
    local lineWords = {}
    local lineLength = 0

    while lineLength < maxw do
      local word = words[math.random(1, #words)]
      if lineLength + #word + 1 > maxw then
        break
      end
      table.insert(lineWords, word)
      lineLength = lineLength + #word + 1 -- +1 for the space
    end

    local line = table.concat(lineWords, " ")
    table.insert(lines, line)
  end

  return lines
end

M.gen_default_lines = function()
  state.default_lines = M.words_to_lines()
  local ui_lines = {}

  for _, v in ipairs(state.default_lines) do
    local line = {}
    for word in string.gmatch(v, "%S+") do
      table.insert(line, { word .. " ", "Comment" })
    end

    table.insert(ui_lines, line)
  end

  state.ui_lines = ui_lines
end

M.gen_lines_diff = function(line, userline)
  local result = {}
  local userlinelen = #userline
  local croppedline = line:sub(1, userlinelen)

  for i = 1, #croppedline do
    local char = line:sub(i, i)
    local expected = userline:sub(i, i)

    local status = char == expected and "Added" or "Removed"

    local resultlen = #result

    expected = expected == " " and char or expected

    if resultlen > 0 and result[resultlen][2] == status then
      result[resultlen][1] = result[resultlen][1] .. expected
    else
      table.insert(result, { expected, status })
    end
  end

  table.insert(result, { line:sub(#userline + 1), "Comment" })

  return result
end

M.count_words = function(ui_line)
  local strs = ""

  for _, v in ipairs(ui_line) do
    -- vim.print{v[2] ,v[1]:sub(1, 1) == " "}
    -- vim.print{v[2] == "Added" and v[1]:sub(1, 1) == " " }
    if v[2] == "Added" and v[1]:sub(-1) == " " then
      strs = strs .. v[1]
    end
  end

  return #strs:gsub("%S+", "")
  --
  -- local count = 0
  --
  --    for _, value in ipairs(state.ui_lines) do
  --      count = count + utils.count_words(value)
  --    end
  --
  --    if count > 0 then
  --      state.stats.wordcount = count
  --    end
end

M.get_accuracy = function()
  local lines = state.ui_lines

  local abc = ""

  for _, line in ipairs(lines) do
    for _, val in ipairs(line) do
      if val[2] == "Added" then
        abc = abc .. val[1]
      end
    end
  end

  local abclen = #abc:gsub("%s+", "")
  local default_words = table.concat(state.default_lines):gsub("%s+", "")
  local accuracy = (abclen / #default_words) * 100
  state.stats.accuracy = math.floor(accuracy)
end

M.gen_keyboard_col = function()
  state.keyboard_col = math.floor(state.w / 2) - 20
end

return M
