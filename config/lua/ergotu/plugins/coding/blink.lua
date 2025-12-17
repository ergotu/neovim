return {
  {
    "blink.cmp",
    event = "InsertEnter",
    before = function()
      LZN.trigger_load("lazydev.nvim")
    end,
    after = function()
      require("blink.cmp").setup({
        enabled = function()
          return not vim.tbl_contains({ "neo-tree" }, vim.bo.filetype)
            and vim.bo.buftype ~= "prompt"
            and vim.b.completion ~= false
        end,
        appearance = {
          use_nvim_cmp_as_default = false,
          nerd_font_variant = "mono",
        },
        completion = {
          accept = {
            auto_brackets = {
              enabled = true,
            },
          },
          menu = {
            auto_show = function(ctx)
              return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
            end,
            border = vim.g.floating_window_options.border,
            winblend = vim.g.floating_window_options.winblend,
            draw = {
              treesitter = { "lsp" },
              gap = 1,
              padding = { 1, 0 },
              columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
              components = {
                kind_icon = {
                  text = function(ctx)
                    local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                    return kind_icon
                  end,
                  -- (optional) use highlights from mini.icons
                  highlight = function(ctx)
                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                    return hl
                  end,
                },
                kind = {
                  -- (optional) use highlights from mini.icons
                  highlight = function(ctx)
                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                    return hl
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
            treesitter_highlighting = true,
            window = {
              border = vim.g.floating_window_options.border,
              winblend = vim.g.floating_window_options.winblend,
            },
          },
          ghost_text = {
            enabled = true,
          },
        },
        signature = {
          enabled = true,
          window = {
            border = vim.g.floating_window_options.border,
            winblend = vim.g.floating_window_options.winblend,
          },
        },
        sources = {
          default = { "lazydev", "lsp", "buffer", "snippets", "path", "omni" },
          providers = {
            path = {
              min_keyword_length = 0,
            },
            buffer = {
              min_keyword_length = 5,
              max_items = 5,
            },
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },
        keymap = {
          preset = "enter",
          ["<C-y>"] = { "select_and_accept" },
        },
      })
    end,
  },
}
