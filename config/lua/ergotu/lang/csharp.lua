local formatting = require("ergotu.config.formatting")
local lsp = require("ergotu.config.lsp")

-- C# LSP Server (omnisharp) with custom handlers
lsp.add_server("omnisharp", {
  cmd = function()
    local bin = vim.fn.exepath("OmniSharp")
    if bin == "" then
      bin = vim.fn.exepath("omnisharp")
    end
    if bin == "" then
      bin = "OmniSharp"
    end
    return {
      bin,
      "-z", -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
      "--hostPID",
      tostring(vim.fn.getpid()),
      "DotNet:enablePackageRestore=false",
      "--encoding",
      "utf-8",
      "--languageserver",
    }
  end,
  handlers = {
    ["textDocument/definition"] = function(...)
      return require("omnisharp_extended").definition_handler(...)
    end,
    -- ["textDocument/typeDefinition"] = function(...)
    --   return require("omnisharp_extended").type_detinition_handler(...)
    -- end,
    -- ["textDocument/references"] = function(...)
    --   return require("omnisharp_extended").references_handler(...)
    -- end,
    -- ["textDocument/implementation"] = function(...)
    --   return require("omnisharp_extended").implementation_handler(...)
    -- end,
  },
  keys = {
    {
      "gd",
      function()
        require("omnisharp_extended").lsp_definitions()
      end,
      desc = "Goto Definition",
    },
    -- {
    --   "gy",
    --   function()
    --     require("omnisharp_extended").lsp_type_definition()
    --   end,
    --   desc = "Goto Definition",
    -- },
    -- {
    --   "gr",
    --   function()
    --     require("omnisharp_extended").lsp_references()
    --   end,
    --   desc = "Goto Definition",
    -- },
    -- {
    --   "gI",
    --   function()
    --     require("omnisharp_extended").implementation_handler()
    --   end,
    --   desc = "Goto Definition",
    -- },
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
    "omnisharp-extended-lsp.nvim",
    lazy = true,
  },
}
