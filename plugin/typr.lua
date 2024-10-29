vim.api.nvim_create_user_command("Typr", function()
  require("typr").open()
end, {})
