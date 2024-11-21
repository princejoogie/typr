local M = {}
local state = require "typr.state"
local config = state.config
local voltui = require "volt.ui"

local tmp_stats = {
  times = 5,
  total_secs = 3001,

  wpm = {
    avg = 70,
    max = 120,
  },

  accuracy = 60,

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

local function secsTodhm(secs)
  local days = math.floor(secs / 86400)
  local hours = math.floor((secs % 86400) / 3600)
  local minutes = math.floor((secs % 3600) / 60)
  return string.format("%02d:%02d:%02d", days, hours, minutes)
end

local function get_lvlstats(my_secs, wpm_ratio)
  local level = math.floor(my_secs / 1000)
  local next_lvl = (level + 1) * 1000
  local next_perc = math.floor(((my_secs + wpm_ratio) / next_lvl) * 100)

  return {
    val = level,
    next_perc = 100 - next_perc,
  }
end

local function readable_date(timestamp)
  local date = os.date("*t", timestamp)
  return string.format("%02d-%02d-%04d %02d:%02d", date.day, date.month, date.year, date.hour, date.min)
end

M.chadstack = function()
  local barlen = state.w_with_pad / 3 - 1
  local wpm_progress = (tmp_stats.wpm.avg / config.wpm_goal) * 100

  local wpm_stats = {
    { { "", "exgreen" }, { "  WPM ~ " }, { tostring(tmp_stats.wpm.avg) .. " / " .. tostring(config.wpm_goal) } },
    {},
    voltui.progressbar {
      w = barlen,
      val = wpm_progress > 100 and 100 or wpm_progress,
      icon = { on = "┃", off = "┃" },
      hl = { on = "exgreen", off = "linenr" },
    },
  }

  local accuracy_stats = {
    { { "", "exred" }, { "  Accuracy ~ " }, { tostring(tmp_stats.accuracy) .. " %" } },
    {},
    voltui.progressbar {
      w = barlen,
      val = tmp_stats.accuracy,
      icon = { on = "┃", off = "┃" },
    },
  }

  local lvl_stats = get_lvlstats(tmp_stats.total_secs, tmp_stats.accuracy)

  local lvl_stats_ui = {
    { { "", "exyellow" }, { "  Level ~ " }, { tostring(lvl_stats.val) } },
    {},
    voltui.progressbar {
      w = barlen,
      val = lvl_stats.next_perc,
      hl = { on = "exyellow" },
      icon = { on = "┃", off = "┃" },
    },
  }

  return voltui.grid_col {
    { lines = wpm_stats, w = barlen, pad = 2 },
    { lines = accuracy_stats, w = barlen, pad = 2 },
    { lines = lvl_stats_ui, w = barlen },
  }
end

M.tabular_stats = function()
  local tb = {
    {
      "  Total time typed",
      "  Tests",
      "  Highest WPM",
    },

    {
      secsTodhm(tmp_stats.total_secs),
      "2100",
      "120 WPM",
    },
  }

  return voltui.table(tb, state.w_with_pad)
end

M.history = function()
  local history_tb = tmp_stats.history
  local tb = {
    { "  WPM", "  Accuracy", "  Time Taken", "  Date" },
  }

  for _, data in ipairs(history_tb) do
    local row = {
      data.wpm,
      data.accuracy .. " %",
      (data.timetaken .. " secs"),
      readable_date(data.timestamp),
    }

    table.insert(tb, row)
  end

  return voltui.table(tb, state.w_with_pad)
end

M.graph = function()
  local wpm_graph_data = {
    val = { 60, 20, 80, 70, 30, 10, 30, 50, 20, 40 },
    footer_label = { " Last 10 WPM stats" },

    format_labels = function(x)
      return tostring((x / 100) * 150)
    end,

    baropts = {
      w = 2,
      gap = 1,
      hl = "exgreen",
      dual_hl = { "exlightgrey", "comment" },
      -- format_hl = function(x)
      --   return x > 50 and "exred" or "normal"
      -- end,
    },
    w = state.w_with_pad / 2,
  }

  local accuracy_graph_data = {
    val = { 60, 20, 80, 70, 30, 10, 30, 50, 20, 40 },
    w = state.w_with_pad / 2,
    footer_label = { "Last 10 Accuracy stats" },
  }

  return voltui.grid_col {
    { lines = voltui.graphs.bar(wpm_graph_data), w = state.w_with_pad / 2, pad = 0 },
    { lines = voltui.graphs.dot(accuracy_graph_data), w = state.w_with_pad / 2, pad = 0 },
  }
end

return M
