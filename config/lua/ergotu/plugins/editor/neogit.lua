return {
  {
    "neogit",
    cmd = "Neogit",
    keys = {
      {
        "<leader>gg",
        function()
          local root = Ergovim.root.get()
          require("neogit").open({ cwd = root })
        end,
        desc = "Neogit (root)",
      },
      {
        "<leader>gG",
        function()
          require("neogit").open()
        end,
        desc = "Neogit (cwd)",
      },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit Pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit Log" },
      { "<leader>gr", "<cmd>Neogit rebase<cr>", desc = "Neogit Rebase" },
      { "<leader>gb", "<cmd>Neogit branch<cr>", desc = "Neogit Branch" },
      { "<leader>gww", "<cmd>Neogit worktree<cr>", desc = "Neogit Worktree" },
    },
    after = function()
      require("neogit").setup({
        process_spinner = false,
        graph_style = "kitty",
        kind = "split_below_all",
        auto_show_console = true,
        integrations = {
          diffview = false,
          snacks = true,
        },
      })
    end,
  },
}
