local M = {}
local state = require "typr.state"
local stats_state = require "typr.stats.state"

M.gen_default_stats = function()
  local default_stats = {
    times = 0,
    total_secs = 0,
    rawpm = 0,
    wpm = { avg = 0, max = 0, min = 0 },
    accuracy = 0,
    rawpm_hist = {},
    wpm_hist = {},
    accuracy_hist = {},
    char_accuracy = {},
    char_times = {},
    char_pressed = {},
  }

  for i = 1, 30 do
    if i <= 10 then
      table.insert(default_stats.wpm_hist, 0)
      table.insert(default_stats.accuracy_hist, 0)
    end

    table.insert(default_stats.rawpm_hist, 0)
  end

  return default_stats
end

M.save_str_tofile = function(tb)
  local str = "'" .. vim.json.encode(tb) .. "'"

  local data = "return string.dump(function()return" .. str .. "end, true)"
  local path = state.config.stats_filepath
  local file = io.open(path, "wb")
  file:write(loadstring(data)())
  file:close()
end

M.restore_stats = function()
  local path = state.config.stats_filepath
  local ok, stats = pcall(dofile, path)

  if ok then
    stats_state.val = vim.json.decode(stats)
  else
    stats_state.val = M.gen_default_stats()
    M.save_str_tofile(stats_state.val)
  end
end

M.save = function()
  local stats = state.stats
  local tmp = stats_state.val

  tmp.times = tmp.times + 1
  local oldtimes = tmp.times - 1
  local times = tmp.times

  -- calc wpm
  tmp.wpm.avg = ((tmp.wpm.avg * oldtimes) + stats.wpm) / times
  tmp.wpm.avg = math.floor(tmp.wpm.avg)
  tmp.wpm.max = (stats.wpm > tmp.wpm.max and stats.wpm) or tmp.wpm.max

  if tmp.wpm.min == 0 then
    tmp.wpm.min = stats.wpm
  else
    tmp.wpm.min = (stats.wpm < tmp.wpm.min and stats.wpm) or tmp.wpm.min
  end

  table.insert(tmp.wpm_hist, 1, tmp.wpm)
  table.remove(tmp.wpm_hist)

  -- calc rawpm
  tmp.rawpm = ((tmp.rawpm * oldtimes) + stats.rawpm) / times
  tmp.rawpm = math.floor(tmp.rawpm)
  table.insert(tmp.rawpm_hist, 1, tmp.rawpm)
  table.remove(tmp.rawpm_hist)

  -- calc accuracy
  tmp.accuracy = ((tmp.accuracy * oldtimes) + stats.accuracy) / times
  tmp.accuracy = math.floor(tmp.accuracy)

  table.insert(tmp.accuracy_hist, 1, tmp.accuracy)
  table.remove(tmp.accuracy_hist)

  tmp.total_secs = tmp.total_secs + state.secs

  -- calc wrong chars
  for k, v in pairs(stats.char_accuracy) do
    local char_avg = tmp.char_accuracy[k] or 100

    tmp.char_accuracy[k] = ((char_avg * oldtimes) + v) / times
    tmp.char_accuracy[k] = math.floor(tmp.char_accuracy[k])
  end

  -- calc char times
  for k, v in pairs(stats.char_times) do
    tmp.char_times[k] = (tmp.char_times[k] or 0) + v
  end

  -- calc char pressed
  for k, v in pairs(stats.char_pressed) do
    if tmp.char_pressed[k] then
      tmp.char_pressed[k] = tmp.char_pressed[k] + v
    else
      tmp.char_pressed[k] = v
    end
  end

  stats_state.val = tmp
  state.stats.char_times = {}

  M.save_str_tofile(tmp)
end

return M
