return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = "ToggleTerm",
  opts = {
    -- HACK: this makes the terminal open similiarily to how vscode does it, but it feels like this is kinda a shit way to do it
    on_open = function(_)
      local name = vim.fn.bufname("neo-tree")
      local winnr = vim.fn.bufwinnr(name)

      if winnr ~= -1 then
        vim.defer_fn(function()
          local cmd = string.format("Neotree toggle")
          vim.cmd(cmd)
          vim.cmd(cmd)
          vim.cmd("wincmd p")
        end, 100)
      end
    end,
  },
}
