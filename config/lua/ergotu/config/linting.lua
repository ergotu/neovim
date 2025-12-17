-- lua/ergotu/config/linting.lua
-- Pure data registry for linter configurations
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
  assert(type(filetype) == "string" and filetype ~= "", "filetype must be non-empty string")
  assert(type(linters) == "table", "linters must be a table")

  if M.config.linters_by_ft[filetype] then
    vim.notify(string.format("Warning: Overwriting linters for filetype '%s'", filetype), vim.log.levels.WARN)
  end

  M.config.linters_by_ft[filetype] = linters
end

--- Add linter configuration override
---@param linter_name string
---@param config table
function M.add_linter_config(linter_name, config)
  assert(type(linter_name) == "string" and linter_name ~= "", "linter_name must be non-empty string")
  assert(type(config) == "table", "config must be a table")

  if M.config.linters[linter_name] then
    vim.notify(string.format("Warning: Overwriting linter config for '%s'", linter_name), vim.log.levels.WARN)
  end

  M.config.linters[linter_name] = vim.tbl_deep_extend("force", M.config.linters[linter_name] or {}, config)
end

return M
