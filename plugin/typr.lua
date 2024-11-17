vim.api.nvim_create_user_command("Typr", function()
  require("typr").open()
end, {})

vim.api.nvim_create_user_command("TyprStats", function()
  require("typr.stats").open()
end, {})
