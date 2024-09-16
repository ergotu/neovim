return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>g<Enter>", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit Pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
      { "<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "Show Branches" },
    },
    opts = {
      kind = "split_below_all",
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
  },
}
