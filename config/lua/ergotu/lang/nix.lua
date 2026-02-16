local langs = require("ergotu.util.langs")
local formatting = langs.formatting
local linting = langs.linting
local lsp = langs.lsp

-- LSP Configuration
lsp.add_server("nixd", {
  cmd = {
    "nixd",
    "--inlay-hints=true",
    "--semantic-tokens=true",
  },
  on_attach = function(client)
    -- We disable everything EXCEPT completions and semantic tokens, since I use
    -- both nixd and nil, and nil is better at everything else
    -- client.server_capabilities.inlayHintProvider = false
    client.server_capabilities.codeActionProvider = nil
    client.server_capabilities.definitionProvider = true
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.documentHighlightProvider = false
    client.server_capabilities.hoverProvider = true
    client.server_capabilities.referencesProvider = false
    client.server_capabilities.renameProvider = false
  end,
  settings = {
    nixpkgs = {
      expr = "import <nixpkgs> { }",
    },
    formatting = {
      command = { "alejandra" },
    },
  },
})
lsp.add_server("nil_ls", {
  on_attach = function(client)
    -- We get completion from nixd, and everything else from nil
    client.server_capabilities.completionProvider = nil
  end,
  settings = {
    ["nil"] = {
      nix = {
        flake = {
          autoArchive = false,
        },
      },
    },
  },
})

-- Formatting Configuration
formatting.add_formatter("nix", { "alejandra" })

-- Linting Configuration
linting.add_linter("nix", { "statix", "deadnix" })
