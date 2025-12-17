-- lua/ergotu/config/testing.lua
-- Pure data registry for test adapter configurations
local M = {}

M.config = {
  -- Test adapters by name
  adapters = {},

  -- Neotest settings
  settings = {
    watch = {
      enabled = true, -- Watch mode enabled per user preference
    },
    output = {
      open_on_run = false,
    },
    quickfix = {
      enabled = true,
      open = false,
    },
    status = {
      enabled = true,
      signs = true,
      virtual_text = false,
    },
    summary = {
      enabled = true,
      expand_errors = true,
    },
  },

  -- Icons (populated from config.icons)
  icons = {},
}

--- Add test adapter for a language
---@param name string Adapter name (e.g., "neotest-go", "neotest-rust")
---@param adapter table|string Adapter configuration or require string
function M.add_adapter(name, adapter)
  assert(type(name) == "string" and name ~= "", "name must be non-empty string")
  assert(type(adapter) == "table" or type(adapter) == "string", "adapter must be table or string")

  if M.config.adapters[name] then
    vim.notify(string.format("Warning: Overwriting test adapter '%s'", name), vim.log.levels.WARN)
  end

  M.config.adapters[name] = adapter
end

--- Update neotest settings
---@param settings table Settings to merge
function M.update_settings(settings)
  assert(type(settings) == "table", "settings must be a table")
  M.config.settings = vim.tbl_deep_extend("force", M.config.settings, settings)
end

return M
