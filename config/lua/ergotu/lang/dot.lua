local langs = Ergovim.langs
local linting = langs.linting
local lsp = langs.lsp

-- Bash/Shell LSP Server
lsp.add_server("bashls", {})

-- Shell Linter
linting.add_linter("sh", { "shellcheck" })
