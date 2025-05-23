return {
  -- catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = false,
      flavor = "macchiato",
      highlight_overrides = {
        all = function(colors)
          return {
            NormalFloat = {
              fg = colors.text,
              bg = colors.none,
            },
          }
        end,
      },
      dim_inactive = {
        enabled = true,
      },
      integrations = {
        aerial = true,
        alpha = true,
        blink_cmp = true,
        cmp = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        indent_blankline = {
          enabled = true,
          scope_color = "mauve",
          colored_indent_levels = true,
        },
        lsp_trouble = true,
        mason = true,
        markdown = true,
        neogit = true,
        render_markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
            ok = { "undercurl" },
          },
          inlay_hints = {
            background = true,
          },
        },
        navic = {
          enabled = true,
          custom_bg = "lualine",
        },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        overseer = true,
        rainbow_delimiters = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
}
