return {
  {
    "direnv.nvim",
    event = "DeferredUIEnter",
    after = function()
      require("direnv").setup({
        autoload_direnv = true,
        notifications = {
          silent_autoload = false,
        },
        statusline = {
          enabled = true,
        },
        keybindings = {
          allow = "<Leader>uea",
          deny = "<Leader>ued",
          reload = "<Leader>uer",
          edit = "<Leader>uee",
        },
      })
    end,
    wk = {
      { "<leader>ue", group = "Direnv" },
    },
  },
}
