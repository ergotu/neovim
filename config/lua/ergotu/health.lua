local M = {}

M.loaded = false

local externals = {
  "date",
  "direnv",
}

M.check = function()
  vim.health.start("Configuration")
  if M.loaded then
    vim.health.ok("loaded properly")
  else
    vim.health.error("didn't load properly")
  end

  vim.health.start("External programs")
  for _, external in ipairs(externals) do
    if vim.fn.executable(external) == 1 then
      vim.health.ok(external .. " found")
    else
      vim.health.error(external .. " not found")
    end
  end

  -- Check LSP servers
  vim.health.start("LSP Servers")
  local langs = require("ergotu.util.langs")
  local lsp_config = langs.lsp.config
  local lsp_checked = {}
  for server_name, _ in pairs(lsp_config.servers) do
    if server_name ~= "*" and not lsp_checked[server_name] then
      lsp_checked[server_name] = true
      local clients = vim.lsp.get_clients({ name = server_name })
      if #clients > 0 then
        vim.health.ok(string.format("%s: running (%d client(s))", server_name, #clients))
      else
        vim.health.info(string.format("%s: configured but not running", server_name))
      end
    end
  end

  -- Check formatters
  vim.health.start("Formatters")
  local formatting_config = langs.formatting.config
  local formatters_checked = {}
  for _, formatters in pairs(formatting_config.formatters_by_ft) do
    for _, formatter in ipairs(formatters) do
      if not formatters_checked[formatter] then
        formatters_checked[formatter] = true
        -- Try to find the formatter executable
        if vim.fn.executable(formatter) == 1 then
          vim.health.ok(string.format("%s: available", formatter))
        else
          vim.health.warn(string.format("%s: not found in PATH", formatter))
        end
      end
    end
  end

  -- Check linters
  vim.health.start("Linters")
  local linting_config = langs.linting.config
  local linters_checked = {}
  for _, linters in pairs(linting_config.linters_by_ft) do
    for _, linter in ipairs(linters) do
      if not linters_checked[linter] then
        linters_checked[linter] = true
        -- Try to find the linter executable
        if vim.fn.executable(linter) == 1 then
          vim.health.ok(string.format("%s: available", linter))
        else
          vim.health.warn(string.format("%s: not found in PATH", linter))
        end
      end
    end
  end

  -- Check debug adapters
  vim.health.start("Debug Adapters")
  local debugging = langs.debugging
  for name, _ in pairs(debugging.config.adapters) do
    vim.health.ok(string.format("Adapter '%s' configured", name))
  end

  -- Check for debuggers in PATH
  local debuggers = { "dlv", "lldb", "codelldb" }
  for _, debugger in ipairs(debuggers) do
    if vim.fn.executable(debugger) == 1 then
      vim.health.ok(string.format("%s found in PATH", debugger))
    else
      vim.health.info(string.format("%s not found in PATH", debugger))
    end
  end

  -- Check test adapters
  vim.health.start("Test Adapters")
  local testing = langs.testing
  for name, _ in pairs(testing.config.adapters) do
    vim.health.ok(string.format("Test adapter '%s' configured", name))
  end

  -- Check plugin loading
  vim.health.start("Plugin Status")
  local lz_loaded = package.loaded["lz.n"]
  if lz_loaded then
    vim.health.ok("lz.n plugin manager loaded")
  else
    vim.health.error("lz.n plugin manager not loaded")
  end
end

M.loaded_exit = function()
  if M.loaded then
    os.exit(0)
  else
    os.exit(1)
  end
end

return M
