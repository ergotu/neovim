local lsp = require("ergotu.config.lsp")

-- C/C++ LSP Server (clangd) with complex configuration
lsp.add_server("clangd", {
  -- root_dir = function(fname)
  --   return require("lspconfig.util").root_pattern(
  --     "Makefile",
  --     "configure.ac",
  --     "configure.in",
  --     "config.h.in",
  --     "meson.build",
  --     "meson_options.txt",
  --     "build.ninja"
  --   )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or vim.fs.dirname(
  --     vim.fs.find(".git", { path = fname, upward = true })[1]
  --   )
  -- end,
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  keys = {
    { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
  },
})

-- Custom setup handler for clangd_extensions
lsp.add_setup("clangd", function(_server, opts)
  -- Use clangd_extensions plugin for enhanced features
  local ok, clangd_ext = pcall(require, "clangd_extensions")
  if ok then
    -- Get any existing clangd_extensions config from opts
    local clangd_ext_opts = opts.clangd_extensions or {}
    clangd_ext.setup(vim.tbl_deep_extend("force", clangd_ext_opts, { server = opts }))
    return true -- skip default lspconfig setup
  end
  return false -- fallback to default setup if plugin not available
end)

-- clangd_extensions plugin for enhanced C/C++ support
---@type lz.n.Spec[]
return {
  {
    "clangd_extensions.nvim",
    lazy = true,
    after = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = false,
        },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
        },
      })
    end,
  },
}
