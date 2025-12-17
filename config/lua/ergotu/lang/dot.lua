local linting = require("ergotu.config.linting")
local lsp = require("ergotu.config.lsp")

-- Bash/Shell LSP Server
lsp.add_server("bashls", {})

-- Shell Linter
linting.add_linter("sh", { "shellcheck" })
