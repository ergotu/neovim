-- lua/ergotu/util/langs/debugging.lua
-- Pure data registry for debug adapter configurations
---@class ergotu.util.langs.debugging
local M = {}

M.config = {
  -- Debug adapters by name
  adapters = {},
  -- Adapter configurations by filetype
  configurations = {},
  -- UI settings
  ui = {
    auto_open = true,
    icons = {},
  },
  -- Virtual text settings
  virtual_text = {
    enabled = true,
    commented = false,
  },
  -- Signs (populated from icons)
  signs = {},
}

--- Add debug adapter
---@param name string Adapter name (e.g., "delve", "codelldb")
---@param adapter table Adapter configuration
function M.add_adapter(name, adapter)
  Ergovim.assert_string(name, "name")
  Ergovim.assert_table(adapter, "adapter")
  Ergovim.set_with_warning(M.config.adapters, name, adapter, {
    merge = true,
    registry_name = "debug adapter",
  })
end

--- Add debug configurations for a filetype
---@param filetype string Filetype (e.g., "go", "rust")
---@param configs table[] Array of configuration objects
function M.add_configuration(filetype, configs)
  Ergovim.assert_string(filetype, "filetype")
  Ergovim.assert_table(configs, "configs")
  Ergovim.set_with_warning(M.config.configurations, filetype, configs, {
    registry_name = "debug configuration",
  })
end

return M
