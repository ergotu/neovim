local formatting = require("ergotu.config.formatting")
local linting = require("ergotu.config.linting")
local lsp = require("ergotu.config.lsp")

-- Markdown LSP Servers
lsp.add_server("marksman", {})
lsp.add_server("harper_ls", {
  filetypes = { "markdown" },
  settings = {
    ["harper-ls"] = {
      linters = {
        spell_check = false,
      },
    },
  },
})

-- Markdown Formatters
formatting.add_formatter("markdown", { "prettier", "markdownlint-cli2", "markdown-toc" })
formatting.add_formatter("markdown.mdx", { "prettier", "markdownlint-cli2", "markdown-toc" })

-- Conditional formatter: markdown-toc (only if <!-- toc --> is found)
formatting.add_formatter_config("markdown-toc", {
  condition = function(_, ctx)
    for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
      if line:find("<!%-%- toc %-%->") then
        return true
      end
    end
    return false
  end,
})

-- Conditional formatter: markdownlint-cli2 (only if markdownlint diagnostics exist)
formatting.add_formatter_config("markdownlint-cli2", {
  condition = function(_, ctx)
    local diag = vim.tbl_filter(function(d)
      return d.source == "markdownlint"
    end, vim.diagnostic.get(ctx.buf))
    return #diag > 0
  end,
})

-- Markdown Linter
linting.add_linter("markdown", { "markdownlint-cli2" })

-- Markdown plugins
---@type lz.n.Spec[]
return {
  -- Markdown preview in browser
  {
    "markdown-preview-nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
        ft = "markdown",
      },
    },
  },
}
