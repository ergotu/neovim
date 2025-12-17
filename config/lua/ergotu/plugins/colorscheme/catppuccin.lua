---@type lz.n.Spec[]
return {
  {
    "catppuccin-nvim",
    colorscheme = "catppuccin",
    after = function()
      require("catppuccin").setup({
        flavor = "auto",
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = true,
        compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
        float = {
          transparent = true,
          solid = false,
        },
        highlight_overrides = {},
        dim_inactive = {
          enabled = false,
        },
        lsp_styles = {
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
        default_integrations = false,
        integrations = {
          blink_cmp = true,
          bufferline = true,
          flash = true,
          grug_far = true,
          gitsigns = true,
          indent_blankline = {
            enabled = true,
            scope_color = "mauve",
            colored_indent_levels = true,
          },
          lualine = true,
          markdown = true,
          mini = true,
          neogit = true,
          noice = true,
          rainbow_delimiters = true,
          render_markdown = true,
          semantic_tokens = true,
          snacks = { enabled = true, scope_color = "mauve" },
          todo_comments = true,
          treesitter = true,
          treesitter_context = true,
          trouble = true,
          which_key = true,
        },
      })
    end,
  },
}
