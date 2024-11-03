local M = {}
local state = require "typr.state"
local words = require "typr.words"
local volt = require "volt"

M.words_to_lines = function()
  local lines = {}
  local maxw = state.w_with_pad - 7

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

    if expected ~= char and expected == " " then
      expected = "x"
    end

    if resultlen > 0 and result[resultlen][2] == status then
      result[resultlen][1] = result[resultlen][1] .. expected
    else
      table.insert(result, { expected, status })
    end
  end

  table.insert(result, { line:sub(#userline + 1), "Comment" })

  return result
end

M.count_correct_words = function()
  local count = 0
  local userlines = {}
  local default_lines = {}
  local unmatched_count = 0

  for _, line in ipairs(state.ui_lines) do
    local strs = ""

    for _, v in ipairs(line) do
      strs = strs .. v[1]
    end

    table.insert(userlines, vim.split(strs, " "))
  end

  for _, line in ipairs(state.default_lines) do
    table.insert(default_lines, vim.split(line, " "))
  end

  for i, line in ipairs(userlines) do
    for j, word in ipairs(line) do
      if default_lines[i][j] == word then
        count = count + 1
      else
        unmatched_count = unmatched_count + 1
      end
    end
  end

  state.stats.correct_word_ratio = count .. " / " .. (count + unmatched_count)
  state.stats.wpm = math.floor((count / state.secs) * 60)
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

M.start_timer = function()
  state.timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      state.secs = state.secs + 1
      volt.redraw(state.buf, "stats")
    end)
  )
end

M.set_emptylines = function()
  local maxline = (state.linecount + state.words_row)
  state.words_row_end = maxline

  local lines = {}

  for i = 1, state.h do
    local str = (i > state.words_row and i <= maxline) and "" or string.rep(" ", state.w_with_pad)
    table.insert(lines, str)
  end

  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
end

M.on_finish = function()
  state.timer:stop()
  vim.cmd.stopinsert()
  M.get_accuracy()
  M.count_correct_words()
  volt.redraw(state.buf, "stats")
end

return M
