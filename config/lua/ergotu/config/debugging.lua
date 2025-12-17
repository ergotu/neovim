-- lua/ergotu/config/debugging.lua
-- Pure data registry for debug adapter configurations
local M = {}

M.config = {
  -- Debug adapters by name
  adapters = {},

  -- Adapter configurations by filetype
  configurations = {},

  -- UI settings
  ui = {
    auto_open = true, -- Auto-open UI on debug start
    icons = {}, -- Populated from config.icons
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
  assert(type(name) == "string" and name ~= "", "name must be non-empty string")
  assert(type(adapter) == "table", "adapter must be a table")

  if M.config.adapters[name] then
    vim.notify(string.format("Warning: Overwriting debug adapter '%s'", name), vim.log.levels.WARN)
  end

  M.config.adapters[name] = vim.tbl_deep_extend("force", M.config.adapters[name] or {}, adapter)
end

--- Add debug configurations for a filetype
---@param filetype string Filetype (e.g., "go", "rust")
---@param configs table[] Array of configuration objects
function M.add_configuration(filetype, configs)
  assert(type(filetype) == "string" and filetype ~= "", "filetype must be non-empty string")
  assert(type(configs) == "table", "configs must be a table")

  if M.config.configurations[filetype] then
    vim.notify(string.format("Warning: Overwriting debug configurations for '%s'", filetype), vim.log.levels.WARN)
  end

  M.config.configurations[filetype] = configs
end

return M
