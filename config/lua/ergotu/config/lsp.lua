-- lua/ergotu/config/lsp.lua
-- Pure data registry for LSP configurations
local M = {}

M.config = {
  servers = {},
  setup = {},
}

function M.add_server(server_name, config)
  assert(type(server_name) == "string" and server_name ~= "", "server_name must be non-empty string")
  assert(type(config) == "table" or config == nil, "config must be a table or nil")

  if M.config.servers[server_name] then
    vim.notify(string.format("Warning: Overwriting LSP server '%s'", server_name), vim.log.levels.WARN)
  end

  M.config.servers[server_name] = vim.tbl_deep_extend("force", M.config.servers[server_name] or {}, config or {})
end

function M.add_setup(server_name, handler)
  assert(type(server_name) == "string" and server_name ~= "", "server_name must be non-empty string")
  assert(type(handler) == "function", "handler must be a function")

  if M.config.setup[server_name] then
    vim.notify(string.format("Warning: Overwriting LSP setup handler for '%s'", server_name), vim.log.levels.WARN)
  end

  M.config.setup[server_name] = handler
end

return M
