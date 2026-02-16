-- lua/ergotu/util/langs/linting.lua
-- Pure data registry for linter configurations
---@class ergotu.util.langs.linting
local M = {}

M.config = {
  -- Linters by filetype
  linters_by_ft = {},
  -- Linter settings/overrides
  linters = {},
}

--- Add linters for a specific filetype
---@param filetype string
---@param linters string[]
function M.add_linter(filetype, linters)
  Ergovim.assert_string(filetype, "filetype")
  Ergovim.assert_table(linters, "linters")
  Ergovim.set_with_warning(M.config.linters_by_ft, filetype, linters, {
    registry_name = "linter",
  })
end

--- Add linter configuration override
---@param linter_name string
---@param config table
function M.add_linter_config(linter_name, config)
  Ergovim.assert_string(linter_name, "linter_name")
  Ergovim.assert_table(config, "config")
  Ergovim.set_with_warning(M.config.linters, linter_name, config, {
    merge = true,
    registry_name = "linter config",
  })
end

return M
