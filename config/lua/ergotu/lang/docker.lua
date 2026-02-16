local langs = Ergovim.langs
local linting = langs.linting
local lsp = langs.lsp

-- Docker LSP Servers
lsp.add_server("dockerls", {})
lsp.add_server("docker_compose_language_service", {})

-- Docker Linter
linting.add_linter("dockerfile", { "hadolint" })
