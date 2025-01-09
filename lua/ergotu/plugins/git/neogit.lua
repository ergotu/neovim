return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit Pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit Log" },
      { "<leader>gr", "<cmd>Neogit rebase<cr>", desc = "Neogit Rebase" },
      { "<leader>gb", "<cmd>Neogit branch<cr>", desc = "Neogit Branch" },
      { "<leader>gw", "<cmd>Neogit worktree<cr>", desc = "Neogit Worktree" },
    },
    opts = {
      process_spinner = false,
      graph_style = "kitty",
      kind = "split_below_all",
      auto_show_console = false,
      integrations = {
        telescope = Util.has("telescope.nvim"),
        fzf_lua = Util.has("fzf-lua"),
        mini_pick = Util.has("mini.pick"),
        diffview = Util.has("diffview.nvim"),
      },
    },
  },
}
