return {
  {
    "zk-nvim",
    event = "DeferredUIEnter",
    after = function()
      require("zk").setup({
        picker = "snacks_picker",
        lsp = {
          config = {
            name = "zk",
            cmd = { "zk", "lsp" },
            filetypes = { "markdown" },
          },
          auto_attach = {
            enabled = true,
          },
        },
      })
    end,
  },
}
