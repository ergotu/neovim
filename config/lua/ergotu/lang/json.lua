local langs = require("ergotu.util.langs")
local lsp = langs.lsp

-- JSON LSP Server with SchemaStore integration
lsp.add_server("jsonls", {
  on_new_config = function(new_config)
    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
    vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
  end,
  settings = {
    json = {
      format = {
        enable = true,
      },
      validate = { enable = true },
      schemas = {
        {
          fileMatch = { "*.hujson" },
          schema = {
            allowTrailingCommas = true,
          },
        },
      },
    },
  },
})

-- SchemaStore plugin for JSON schemas
---@type lz.n.Spec[]
return {
  {
    "SchemaStore-nvim",
    lazy = true,
    version = false,
  },
}
