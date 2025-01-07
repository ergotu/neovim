return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    opts = {
      options = {
        use_icons_from_diagnostic = true,
        show_source = true,
        multilines = {
          enabled = true,
        },
      },
    },
  },
}
