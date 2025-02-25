return {
  {
    "Juksuu/worktrees.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>gws",
        function()
          Snacks.picker.worktrees()
        end,
        desc = "Pick Worktree",
      },
      {
        "<leader>gwa",
        "<cmd>GitWorktreeCreate<cr>",
        desc = "Create Worktree",
      },
      {
        "<leader>gwA",
        "<cmd>GitWorktreeCreateExisting<cr>",
        desc = "Create Worktree (Existing Branch)",
      },
    },
    opts = {},
  },
}
