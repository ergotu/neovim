-- lua/ergotu/util/langs/formatting.lua
-- Pure data registry for formatter configurations
---@class ergotu.util.langs.formatting
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
  Ergovim.assert_string(filetype, "filetype")
  Ergovim.assert_table(formatters, "formatters")
  Ergovim.set_with_warning(M.config.formatters_by_ft, filetype, formatters, {
    registry_name = "formatter",
  })
end

--- Add formatter override configuration
---@param formatter_name string
---@param config table
function M.add_formatter_config(formatter_name, config)
  Ergovim.assert_string(formatter_name, "formatter_name")
  Ergovim.assert_table(config, "config")
  Ergovim.set_with_warning(M.config.formatters, formatter_name, config, {
    merge = true,
    registry_name = "formatter config",
  })
end

return M
