local vo = vim.opt_local
vo.tabstop = 4
vo.shiftwidth = 4
vo.softtabstop = 4

vim.api.nvim_create_user_command("GoModTidy", function()
  vim.cmd.LspStop()
  vim.cmd("!go mod tidy -v")
  vim.cmd.write()
  vim.cmd.LspStart()
end, {})
