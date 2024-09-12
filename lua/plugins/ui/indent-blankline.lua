-- indent guides for Neovim
return {
  "lukas-reineke/indent-blankline.nvim",
  event = "LazyFile",
  opts = function()
    return {
      indent = {
        char = "▎",
        tab_char = "▎",
      },
      scope = { enabled = true, show_start = true, show_end = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    }
  end,
  main = "ibl",
}
