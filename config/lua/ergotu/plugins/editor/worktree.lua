---@type lz.n.Spec[]
return {
  {
    "worktrees.nvim",
    cmd = { "WorktreeAdd", "WorktreeRemove", "WorktreeSwitch" },
    after = function()
      require("worktrees").setup()
    end,
    before = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "WorktreeCreated",
        group = vim.api.nvim_create_augroup("ergotu_worktree", { clear = true }),
        callback = function(ev)
          -- Auto-allow direnv in new worktree
          io.popen("direnv allow " .. ev.data.path)
        end,
      })
    end,
  },
}
