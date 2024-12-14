local M = {}
local state = require "typr.state"
local config = state.config
local voltui = require "volt.ui"
local stats = require "typr.stats.state"
local kblayouts = require "typr.constants.kblayouts"

local tmp_stats = {
  times = 5,
  total_secs = 3001,

  wpm = {
    avg = 70,
    max = 120,
  },

  accuracy = 60,
}

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

M.progress = function()
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
      "  Total time",
      "  Tests",
      "  Lowest WPM",
      "  Highest WPM",
    },

    {
      secsTodhm(tmp_stats.total_secs),
      "2100",
      "60 WPM",
      "120 WPM",
    },
  }

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

M.rawpm = function()
  local m = { 60, 20, 80, 70, 30, 20, 80, 70, 30, 80, 70, 30, 50 }
  local n = { 60, 20, 80, 70, 30, 20, 80, 70, 30, 80, 70, unpack(m) }

  local wpm_graph_data = {
    val = { 60, 20, 80, 70, 30, 10, 30, 50, 20, 40, unpack(n) },
    footer_label = { " Last 20 RAW WPM stats" },

    format_labels = function(x)
      return tostring((x / 100) * 150)
    end,

    baropts = {
      w = 1,
      gap = 1,
      format_hl = function(x)
        return x > 30 and "exred" or "normal"
      end,
    },
    w = state.w_with_pad / 2,
  }

  return voltui.graphs.bar(wpm_graph_data)
end

local border_chars = {
  mid = { top = "┬", bot = "┴", none = "┼" },
  corners_left = { top = "┌", bot = "└", none = "├" },
  corners_right = { top = "┐", bot = "┘", none = "┤" },
  vline = "│",
}

M.keys_accuracy = function()
  local x = stats.val.char_accuracy
  local lines = {}
  local line = string.rep("─", (10 * 4) + 1)

  for i, v in ipairs(kblayouts[config.kblayout]) do
    local row = {}

    for _, letter in ipairs(v) do
      local score = x[letter] or 100
      local hl = score == 100 and "TyprGrey" or "TyprRed"

      if score > 90 and score < 100 then
        hl = "TyprYellow"
      end

      table.insert(row, { " " .. letter:upper() .. " ", hl })
      table.insert(row, { " " })
    end

    table.remove(row)

    if i ~= 1 then
      table.insert(lines, { { border_chars.corners_left.none .. line .. border_chars.corners_right.none, "linenr" } })
    end

    table.insert(row, 1, { border_chars.vline .. " ", "linenr" })
    table.insert(row, { " " .. border_chars.vline, "linenr" })
    table.insert(lines, row)

    if i == 1 then
      table.insert(lines, 1, { { border_chars.corners_left.top .. line .. border_chars.corners_right.top, "linenr" } })
    elseif i == 3 then
      table.insert(lines, { { border_chars.corners_left.bot .. line .. border_chars.corners_right.bot, "linenr" } })
    end
  end

  table.insert(lines, 1, { { "   Average of Key Accuracies" } })

  local indicators = {
    { { "" } },
    { { "" } },
    { { "󱓻 ", "comment" }, { "100% accuracy!" } },
    { { "󱓻 ", "exyellow" }, { "Less than 90%" } },
    { { "󱓻 ", "exred" }, { "Less than 80%" } },
    { { "" } },
    { { "Inaccurate keys: ", "exred" }, { "a z i", "exlightgrey" } },
  }

  return voltui.grid_col {
    { lines = lines, w = state.w_with_pad - 32, pad = 2 },
    { lines = indicators, w = 20 },
  }
end

local slice_tb = function(tb, start, stop)
  local result = {}

  local kek = start > stop and -1 or 1

  for i = start, stop, kek do
    table.insert(result, tb[i])
  end

  return result
end

M.char_times = function()
  local char_times = stats.val.char_times
  local wrong_counts = stats.val.char_accuracy
  local list = {}

  for k, v in pairs(char_times) do
    v = math.floor(v * 10) / 10
    table.insert(list, { k, v, (wrong_counts[k] or 0) })
  end

  table.sort(list, function(a, b)
    return a[2] > b[2]
  end)

  local tb1 = slice_tb(list, 1, 5)
  table.insert(tb1, 1, { "Key", "Time" })

  tb1 = vim.tbl_map(function(x)
    return { { x[1], "exred" }, x[2] }
  end, tb1)

  local tb2 = slice_tb(list, #list, #list - 4)
  table.insert(tb2, 1, { "Key", "Time" })

  tb2 = vim.tbl_map(function(x)
    return { { x[1], "exblue" }, x[2] }
  end, tb2)

  local w = (state.w_with_pad / 2) - 21

  return voltui.grid_col {
    { lines = voltui.table(tb1, w, "normal", { "Slowest keys" }), pad = 1, w = w },
    { lines = voltui.table(tb2, w, "normal", { "Fastest keys" }), pad = 1, w = w },
  }
end

return M
