return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit Pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit Log" },
      { "<leader>gr", "<cmd>Neogit rebase<cr>", desc = "Neogit Rebase" },
      { "<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "Show Branches" },
    },
    opts = {
      graph_style = "unicode",
      kind = "split_below_all",
      auto_show_console = false,
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
  },
}
