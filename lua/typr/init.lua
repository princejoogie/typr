local M = {}
local api = vim.api
local state = require "typr.state"
local layout = require "typr.ui.layout"
local volt = require "volt"
local utils = require "typr.utils"

state.ns = api.nvim_create_namespace "Typr"

M.setup = function(opts) end

M.open = function()
  state.buf = api.nvim_create_buf(false, true)
  utils.gen_default_lines()
  utils.gen_keyboard_col()

  volt.gen_data {
    { buf = state.buf, layout = layout, xpad = state.xpad, ns = state.ns },
  }

  state.win = api.nvim_open_win(state.buf, true, {
    row = (vim.o.lines / 2) - (state.h / 2),
    col = (vim.o.columns / 2) - (state.w / 2),
    width = state.w,
    height = state.h,
    relative = "editor",
    style = "minimal",
    border = "single",
    title = { { " Typr ", "ExBlack3bg" } },
    title_pos = "center",
  })

  api.nvim_win_set_hl_ns(state.win, state.ns)

  api.nvim_set_hl(state.ns, "FloatBorder", { link = "Exdarkborder" })
  api.nvim_set_hl(state.ns, "Normal", { link = "ExdarkBg" })

  api.nvim_set_current_win(state.win)

  volt.run(state.buf, {
    h = 10,
    w = state.w - (2 * state.xpad),
    custom_empty_lines = function()
      local maxline = (state.linecount + 2)
      local lines = {}

      for i = 1, state.h do
        local str = i < maxline and "" or string.rep(" ", state.w)
        table.insert(lines, str)
      end

      api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    end,
  })

  require("volt.events").add(state.buf)

  ----------------- keymaps --------------------------
  volt.mappings {
    bufs = { state.buf },
  }

  vim.bo[state.buf].filetype = "typr"
  vim.bo[state.buf].ma = true
  vim.wo[state.win].virtualedit = "all"

  api.nvim_win_set_cursor(state.win, { 2, 2 })

  api.nvim_buf_attach(state.buf, false, {
    on_lines = function(_, _, _, line)
      local curline = api.nvim_get_current_line():sub(3)
      local default_line = state.default_lines[line]

      state.ui_lines[line] = utils.gen_lines_diff(default_line, curline)

      api.nvim_buf_set_extmark(state.buf, state.ns, line, 0, {
        virt_text = state.ui_lines[line],
        virt_text_win_col = state.xpad,
        id = line + 1,
      })

      utils.get_accuracy()
      -- vim.print(state.stats.accuracy)
      volt.redraw(state.buf, "stats")

      state.lastchar = curline:sub(-1)
      volt.redraw(state.buf, "keyboard")
    end,
  })

  vim.keymap.set("i", "<Space>", function()
    local pos = vim.api.nvim_win_get_cursor(state.win)

    if pos[2] > #state.default_lines[pos[1] - 1] then
      api.nvim_win_set_cursor(state.win, { pos[1] + 1, 2 })
    else
      api.nvim_feedkeys(" ", "n", true)
    end
  end, { buffer = state.buf })
end

return M
