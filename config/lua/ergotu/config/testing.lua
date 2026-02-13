-- lua/ergotu/config/testing.lua
-- Pure data registry for test adapter configurations
local M = {}

M.config = {
  -- Test adapters by name
  adapters = {},
  -- Neotest settings
  settings = {
    watch = {
      enabled = true,
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
  Ergovim.assert_string(name, "name")
  assert(type(adapter) == "table" or type(adapter) == "string", "adapter must be table or string")
  Ergovim.set_with_warning(M.config.adapters, name, adapter, {
    registry_name = "test adapter",
  })
end

--- Update neotest settings
---@param settings table Settings to merge
function M.update_settings(settings)
  Ergovim.assert_table(settings, "settings")
  M.config.settings = vim.tbl_deep_extend("force", M.config.settings, settings)
end

return M
