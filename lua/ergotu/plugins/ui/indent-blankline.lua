-- indent guides for Neovim
return {
  "lukas-reineke/indent-blankline.nvim",
  event = "LazyFile",
  opts = function()
    Snacks.toggle({
      name = "Indentation Guides",
      get = function()
        return require("ibl.config").get_config(0).enabled
      end,
      set = function(state)
        require("ibl").setup_buffer(0, { enabled = state })
      end,
    }):map("<leader>ug")

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
