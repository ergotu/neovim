return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        expand = function(snippet)
          return Util.cmp.expand(snippet)
        end,
      },
      sources = {
        default = { "snippets" },
      },
    },
  },
}
