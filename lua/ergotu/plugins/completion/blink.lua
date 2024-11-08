return {
  {
    "saghen/blink.cmp",
    cond = vim.g.use_blink,
    version = "*",
    opts_extend = { "sources.completion.enabled_providers" },
    dependencies = {
      -- { "saghen/blink.compat", opts = {} },
    },
    event = "InsertEnter",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      nerd_font_variant = "mono",
      windows = {
        autocomplete = {
          draw = "reversed",
          border = vim.g.floating_window_options.border,
          winblend = vim.g.floating_window_options.winblend,
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
      accept = {
        auto_brackets = {
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
  },
  -- add icons
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.kind_icons = Util.config.icons.kinds
    end,
  },
}
