vim.keymap.set("n", "qq", function()
  vim.cmd.quit()
end, { buffer = 0, desc = "close help window" })

vim.cmd(15 .. "wincmd_")

Util.config.kind_filter.help = false
