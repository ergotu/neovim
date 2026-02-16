-- lua/ergotu/util/langs/lsp.lua
-- Pure data registry for LSP configurations
---@class ergotu.util.langs.lsp
local M = {}

M.config = {
  servers = {},
  setup = {},
}

--- Add LSP server configuration
---@param server_name string
---@param config table|nil
function M.add_server(server_name, config)
  Ergovim.assert_string(server_name, "server_name")
  assert(type(config) == "table" or config == nil, "config must be a table or nil")
  Ergovim.set_with_warning(M.config.servers, server_name, config or {}, {
    merge = true,
    registry_name = "LSP server",
  })
end

--- Add custom LSP setup handler
---@param server_name string
---@param handler function
function M.add_setup(server_name, handler)
  Ergovim.assert_string(server_name, "server_name")
  assert(type(handler) == "function", "handler must be a function")
  Ergovim.set_with_warning(M.config.setup, server_name, handler, {
    registry_name = "LSP setup handler",
  })
end

return M
