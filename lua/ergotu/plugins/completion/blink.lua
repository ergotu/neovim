---@diagnostic disable: missing-fields
return {
  {
    "saghen/blink.cmp",
    cond = vim.g.use_blink,
    version = "*",
    opts_extend = { "sources.completion.enabled_providers" },
    dependencies = {
      {
        "saghen/blink.compat",
        optional = true,
        opts = {},
        version = "*",
      },
    },
    event = "InsertEnter",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      nerd_font_variant = "mono",
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          border = vim.g.floating_window_options.border,
          winblend = vim.g.floating_window_options.winblend,
          draw = {
            treesitter = true,
            gap = 1,
            padding = { 1, 0 },
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            components = {
              kind_icon = {
                text = function(ctx)
                  return ctx.kind_icon .. ctx.icon_gap
                end,
                width = { fill = true },
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          border = vim.g.floating_window_options.border,
          winblend = vim.g.floating_window_options.winblend,
        },
        signature_help = {
          border = vim.g.floating_window_options.border,
          winblend = vim.g.floating_window_options.winblend,
        },
        ghost_text = {
          enabled = true,
        },
      },
      trigger = {
        signature_help = {
          enabled = true,
        },
      },
      sources = {
        completion = {
          compat = {},
          enabled_providers = { "lsp", "path", "buffer" },
        },
      },
      keymap = {
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },

        ["<C-e>"] = { "hide", "fallback" },
        ["<Esc>"] = { "hide", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
      },
    },
    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      -- setup compat sources
      local enabled = opts.sources.completion.enabled_providers
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end
      require("blink.cmp").setup(opts)
    end,
  },
  -- add icons
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = Util.config.icons.kinds
    end,
  },
}
