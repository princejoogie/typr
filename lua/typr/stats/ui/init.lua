local M = {}
local state = require "typr.state"
local voltui = require "volt.ui"

local tmp_stats = {
  times = 5,
  total_secs = 1201221,

  wpm = {
    avg = 70,
    max = 120,
  },

  history = {
    {
      wpm = 38.40,
      raw = 44.41,
      accuracy = 60,
      timestamp = 1731765938,
      timetaken = 50,
    },
  },
}

table.insert(tmp_stats.history, tmp_stats.history[1])
table.insert(tmp_stats.history, tmp_stats.history[1])
table.insert(tmp_stats.history, tmp_stats.history[1])

local function secsToHHMM(secs)
  local hours = math.floor(secs / 3600)
  local minutes = math.floor((secs % 3600) / 60)
  return string.format("%02d:%02d", hours, minutes)
end

local function readable_date(timestamp)
  local date = os.date("*t", timestamp)
  return string.format("%02d-%02d-%04d %02d:%02d", date.day, date.month, date.year, date.hour, date.min)
end

M.stats = function()
  local v = (tmp_stats.wpm.avg / state.config.wpm_goal) * 100

  local wpm_progress = voltui.progressbar {
    w = state.w_with_pad / 3 - 2,
    val = v > 100 and 100 or v,
    icon = { on = "|", off = "|" },
  }

  local function bru()
    print "stats 1?"
    -- require("volt").redraw(state.statsbuf, "stats")
  end

  return {
    { { "  WPM ~ ", "", bru }, { "80" } },
    {},
    wpm_progress,
  }
end

M.chadstack = function()
  return voltui.grid_col {
    { lines = M.stats(), w = (state.w_with_pad / 3), pad = 1 },
    { lines = M.stats(), w = (state.w_with_pad / 3), pad = 1 },
    { lines = M.stats(), w = (state.w_with_pad / 3) },
  }
end

M.history = function()
  local history_tb = tmp_stats.history

  local mytable = {

    -- { "  WPM", "  Accuracy", "  Correct word ratio" },

    { "  WPM", "  Raw", "  Accuracy", "  Time Taken", "  Date" },
  }

  for _, data in ipairs(history_tb) do
    local row = {
      data.wpm,
      data.raw,
      data.accuracy .. " %",
      (data.timetaken .. " secs"),
      readable_date(data.timestamp),
    }

    table.insert(mytable, row)
  end

  return voltui.table(mytable, state.w_with_pad)
end

return M
