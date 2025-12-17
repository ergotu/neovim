local formatting = require("ergotu.config.formatting")
local lsp = require("ergotu.config.lsp")

-- C# LSP Server (omnisharp) with custom handlers
lsp.add_server("omnisharp", {
  cmd = { "Omnisharp" },
  handlers = {
    ["textDocument/definition"] = function(...)
      return require("omnisharp_extended").handler(...)
    end,
  },
  keys = {
    {
      "gd",
      function()
        require("omnisharp_extended").lsp_definitions()
      end,
      desc = "Goto Definition",
    },
  },
  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = true,
      OrganizeImports = true,
    },
    MsBuild = {
      LoadProjectsOnDemand = nil,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = true,
      EnableImportCompletion = true,
      AnalyzeOpenDocumentsOnly = true,
    },
    Sdk = {
      IncludePrereleases = true,
    },
  },
})

-- C# Formatter
formatting.add_formatter("cs", { "csharpier" })
formatting.add_formatter_config("csharpier", {
  command = "dotnet-csharpier",
  args = { "--write-stdout" },
})

-- omnisharp_extended plugin for improved goto definition
---@type lz.n.Spec[]
return {
  {
    "omnisharp-extended-lsp-nvim",
    lazy = true,
  },
}
