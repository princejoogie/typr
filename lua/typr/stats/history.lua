local state = require "typr.state"
local voltui = require "volt.ui"
local stats = require "typr.stats.state"

local tabular_stats = function()
  local dum = {
    "21 s",
    "60",
    "150",
    "99%",
  }

  local tb = {
    {
      "Time",
      "WPM",
      "RAW",
      "Accuracy",
    },
  }

  for i = 1, 8 do
    table.insert(tb, dum)
  end

  local w1 = state.w_with_pad - 30
  local w2 = 29

  local goalTb = {
    { { { "  WPM GOAL ~ 150", "normal" } } },
  }

  local progressbar = voltui.progressbar {
    w = w2 - 4,
    val = 60,
    hl = { on = "exblue" },
    icon = { on = "|", off = "|" },
  }

  for _, _ in ipairs(tb) do
    table.insert(goalTb, { progressbar })
  end
  table.remove(goalTb)

  return voltui.grid_col {
    {
      lines = voltui.table(tb, w1),
      w = w1,
      pad = 1,
    },
    {
      lines = voltui.table(goalTb, w2),
      w = w2,
    },
  }
end

local rawpm = function()
  local char_times = stats.val.char_times
  local sum = 0

  for _, v in pairs(char_times) do
    sum = sum + v
  end

  local footerTxt = ""
  local data = {}

  for i = 97, 122 do
    local char = string.char(i)
    char_times[char] = char_times[char] or 0
    data[char] = math.floor((char_times[char] / sum) * 1000)
    footerTxt = footerTxt .. char .. (i ~= 122 and " " or "")
  end

  local dotdata = {}

  for i = 97, 122 do
    table.insert(dotdata, data[string.char(i)])
  end

  local wpm_graph_data = {
    val = dotdata,

    format_labels = function(x)
      return tostring((x / 100) * 150)
    end,

    baropts = {
      w = 1,
      gap = 1,
      sidelabels = false,
      icons = { on = "󰄰", off = "·" },

      format_hl = function(x)
        if x > 60 then
          return "exred"
        end
        return x > 30 and "exblue" or "exgreen"
      end,

      format_icon = function(x)
        if x < 40 then
          return ""
        elseif x > 20 then
          return "󰄰"
        end
      end,
    },
    w = state.w_with_pad / 2,
  }

  local lines = voltui.graphs.dot(wpm_graph_data)
  local linew = voltui.line_w(lines[1])
  table.insert(lines, { { string.rep("─", linew), "comment" } })
  table.insert(lines, { { footerTxt, "exlightgrey" } })
  voltui.border(lines)

  return lines
end

return function()
  return require("volt.ui").grid_row {
    { { { "   History of last 7 tests" } } },

    tabular_stats(),
    { {} },
    { { { " Average speed of each key per test (lower is better)" } } },
    rawpm(),
  }
end
