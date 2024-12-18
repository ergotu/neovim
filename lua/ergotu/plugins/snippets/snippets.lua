return {
  {
    "nvim-cmp",
    dependencies = {
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
        },
        dependencies = {
          "rafamadriz/friendly-snippets",
        },
      },
    },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(item)
          Util.cmp.expand(item.body)
        end,
      }
      if Util.has("nvim-snippets") then
        table.insert(opts.sources, { name = "snippets", priority = 1000 })
      end
    end,
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        completion = {
          enabled_providers = { "snippets" },
        },
      },
    },
  },
}
