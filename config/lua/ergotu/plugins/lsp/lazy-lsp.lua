return {
  {
    "lazy-lsp.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    before = function()
      LZN.trigger_load("nvim-lspconfig")
    end,
    after = function()
      require("lazy-lsp").setup({
        use_vim_lsp_config = true,
      })
    end,
  },
}
