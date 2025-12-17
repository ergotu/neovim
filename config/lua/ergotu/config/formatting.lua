-- lua/ergotu/config/formatting.lua
-- Pure data registry for formatter configurations
local M = {}

M.config = {
  -- Default format options
  default_format_opts = {
    timeout_ms = 3000,
    async = false,
    quiet = false,
    lsp_format = "fallback",
  },
  -- Formatters by filetype
  formatters_by_ft = {
    -- Use the "_" filetype to run formatters on filetypes that don't
    -- have other formatters configured.
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
  -- Format on save settings
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
  -- Formatter overrides
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
}

--- Add formatters for a specific filetype
---@param filetype string
---@param formatters string[]
function M.add_formatter(filetype, formatters)
  assert(type(filetype) == "string" and filetype ~= "", "filetype must be non-empty string")
  assert(type(formatters) == "table", "formatters must be a table")

  if M.config.formatters_by_ft[filetype] then
    vim.notify(string.format("Warning: Overwriting formatters for filetype '%s'", filetype), vim.log.levels.WARN)
  end

  M.config.formatters_by_ft[filetype] = formatters
end

--- Add formatter override configuration
---@param formatter_name string
---@param config table
function M.add_formatter_config(formatter_name, config)
  assert(type(formatter_name) == "string" and formatter_name ~= "", "formatter_name must be non-empty string")
  assert(type(config) == "table", "config must be a table")

  if M.config.formatters[formatter_name] then
    vim.notify(string.format("Warning: Overwriting formatter config for '%s'", formatter_name), vim.log.levels.WARN)
  end

  M.config.formatters[formatter_name] = vim.tbl_deep_extend("force", M.config.formatters[formatter_name] or {}, config)
end

return M
