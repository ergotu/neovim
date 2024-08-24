return {
  {
    "otavioschwanck/arrow.nvim",
    event = "LazyFile",
    opts = {
      show_icons = true,
      seperate_by_branch = true,
      leader_key = ";", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
      window = {
        border = vim.g.floating_window_options.border,
      },
    },
  },
}
