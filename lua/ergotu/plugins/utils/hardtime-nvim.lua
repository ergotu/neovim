return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    event = "LazyFile",
    opts = {
      disable_mouse = false,
      disabled_filetypes = { "qf", "netrw", "neo-tree", "lazy", "mason", "oil", "Neogit*", "GitGraph", "gitsigns*" },
    },
  },
}
