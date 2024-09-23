Util.on_very_lazy(function()
  vim.filetype.add({
    extension = { mdx = "markdown.mdx" },
  })
end)
return {
  {
    "folke/zen-mode.nvim",
    keys = {
      {
        "<leader>uz",
        function()
          require("zen-mode").toggle()
        end,
        desc = "Toggle Zen Mode",
      },
    },
    opts = {
      window = {
        background = 0.75,
        width = 0.5,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      formatters_by_ft = {
        ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "markdownlint-cli2", "markdown-toc" } },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
        harper_ls = {
          filetypes = {
            "markdown",
          },
          settings = {
            ["harper-ls"] = {
              linters = {
                spell_check = false,
              },
            },
          },
        },
      },
    },
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = not vim.g.use_markview,
    dependencies = {
      {
        "echasnovski/mini.icons",
      },
      {
        "nvim-treesitter/nvim-treesitter",
      },
    },
    opts = {
      file_types = { "markdown", "norg", "rmd", "org" },
      preset = "lazy",
    },
    ft = { "markdown", "norg", "rmd", "org" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Util.toggle.map("<leader>um", {
        name = "Render Markdown",
        get = function()
          return require("render-markdown.state").enabled
        end,
        set = function(enabled)
          local m = require("render-markdown")
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      })
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    enabled = vim.g.use_markview,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown", "norg", "rmd", "org" },
    opts = {
      modes = { "n", "no", "c" },
      hybrid_modes = { "n" },
      callbacks = {
        on_enable = function(_, win)
          vim.wo[win].conceallevel = 2
          vim.wo[win].concealcursor = "nc"
        end,
      },
    },
    config = function(_, opts)
      require("markview").setup(opts)
      Util.toggle.map("<leader>um", {
        name = "Render Markdown",
        get = function()
          return require("markview").state.enable
        end,
        set = function(state)
          local mc = require("markview").commands
          if state then
            mc.enableAll()
          else
            mc.disableAll()
          end
        end,
      })
    end,
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
      -- refer to `:h file-pattern` for more examples
      "BufReadPre "
        .. vim.fn.expand("~")
        .. "/vaults/personal",
      "BufNewFile " .. vim.fn.expand("~") .. "/vaults/personal",
    },
    dependencies = {
      -- Required.
      {
        "nvim-lua/plenary.nvim",
      },
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
        {
          name = "work",
          path = "~/vaults/work",
        },
        {
          name = "no-vault",
          path = function()
            return assert(vim.fn.getcwd())
            -- return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
          end,
          overrides = {
            notes_subdit = vim.NIL, -- Have to use vim.NIL instead of 'nil'
            new_notes_location = "current_dir",
            templates = {
              folder = vim.NIL,
            },
            disable_frontmatter = true,
          },
        },
      },
    },
  },
}
