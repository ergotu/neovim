local langs = require("ergotu.util.langs")
local formatting = langs.formatting
local linting = langs.linting
local lsp = langs.lsp

-- Go LSP Server with extensive configuration
lsp.add_server("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        gc_details = true,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        fieldalignment = true,
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
})

-- Custom setup handler for gopls semantic tokens workaround
lsp.add_setup("gopls", function(_server, _opts)
  -- Workaround for gopls not supporting semanticTokensProvider
  -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
  Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
    if not client.server_capabilities.semanticTokensProvider then
      local semantic = client.config.capabilities.textDocument.semanticTokens
      client.server_capabilities.semanticTokensProvider = {
        full = true,
        legend = {
          tokenTypes = semantic.tokenTypes,
          tokenModifiers = semantic.tokenModifiers,
        },
        range = true,
      }
    end
  end)
  return false -- use default lspconfig setup
end)

-- Go Formatters
formatting.add_formatter("go", { "goimports", "gofumpt" })

-- Go Linter
linting.add_linter("go", { "golangcilint" })

-- Debug adapter for Go (Delve)
local debugging = langs.debugging
debugging.add_adapter("delve", {
  type = "server",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
})

debugging.add_configuration("go", {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}",
  },
  {
    type = "delve",
    name = "Debug test",
    request = "launch",
    mode = "test",
    program = "${file}",
  },
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
})

-- Test adapter for Go
local testing = langs.testing
testing.add_adapter("neotest-go", "neotest-go")
