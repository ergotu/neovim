return {
  {
    "NotAShelf/direnv.nvim",
    event = "VeryLazy",
    opts = {
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
    },
  },
}
