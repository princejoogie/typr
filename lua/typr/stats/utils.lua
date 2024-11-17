local M = {}
local state = require "typr.state"

M.restore_stats = function()
  local path = state.config.stats_filepath
  local ok, stats = pcall(dofile, path)
  state.stats_history = ok and stats or {}
end

M.dict_to_str = function(tb)
  local str = "{"

  for k, v in pairs(tb) do
    local key = "['" .. k .. "']"
    local val = type(v) == "string" and '"' .. v .. '"' or v
    local keyval = key .. "=" .. val .. ","
    str = str .. keyval
  end

  return str .. "}"
end

M.tb_to_str = function(tb)
  local str = "return {"

  for _, v in ipairs(tb) do
    str = str .. M.dict_to_str(v) .. ","
  end

  str = str .. "}"

  return "return string.dump(function()" .. str .. "end, true)"
end

M.save = function(stat)
  table.insert(state.stats_history, stat)

  local path = state.config.stats_filepath
  local data = M.tb_to_str(state.stats_history)

  local file = io.open(path, "wb")
  file:write(loadstring(data)())
  file:close()

  M.restore_stats()
end

return M
