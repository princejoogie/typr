local ui = require "typr.ui"

local abc = {
  lines = function()
    return { {} }
  end,
  name = "kekw",
}

return {

  abc,

  {
    lines = ui.words,
    name = "words",
  },

  abc,

  {
    lines = ui.stats,
    name = "stats",
  },
}
