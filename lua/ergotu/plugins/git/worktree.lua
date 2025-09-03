return {
  {
    "ergotu/worktrees.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "WorktreeCreated",
        group = vim.api.nvim_create_augroup("ergotu", { clear = true }),
        callback = function(ev)
          io.popen("direnv allow " .. ev.data.path)
        end,
      })
    end,
  },
}
