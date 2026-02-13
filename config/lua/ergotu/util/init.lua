---@class ergotu.util
---@field root ergotu.util.root
---@field lualine ergotu.util.lualine
local M = {}

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ergotu.util." .. k)
    return t[k]
  end,
})

function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

--- Wrap a callback with pcall and notify on error
--- Reduces boilerplate in autocmd definitions
---@param name string Name for error messages
---@param fn function The callback to wrap
---@return function wrapped_callback
function M.safe_callback(name, fn)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      vim.notify(string.format("Autocmd '%s' failed: %s", name, tostring(err)), vim.log.levels.WARN)
    end
  end
end

--- Create an augroup with ergovim_ prefix
---@param name string Group name (without prefix)
---@return integer group_id
function M.augroup(name)
  return vim.api.nvim_create_augroup("ergovim_" .. name, { clear = true })
end

--- Set a value with overwrite warning
--- Helper for registry modules to reduce boilerplate
---@param tbl table The table to set in
---@param key string The key to set
---@param value any The value to set
---@param opts table|nil Options
---  - merge: boolean Merge tables instead of replace (default: false)
---  - warn_msg: string|nil Custom warning message (uses key if not provided)
---  - registry_name: string Registry name for warning message
function M.set_with_warning(tbl, key, value, opts)
  opts = opts or {}
  local merge = opts.merge or false
  local warn_msg = opts.warn_msg or key
  local registry_name = opts.registry_name or "registry"

  if tbl[key] then
    vim.notify(string.format("Warning: Overwriting %s '%s'", registry_name, warn_msg), vim.log.levels.WARN)
  end

  if merge and type(value) == "table" then
    tbl[key] = vim.tbl_deep_extend("force", tbl[key] or {}, value)
  else
    tbl[key] = value
  end
end

--- Assert a non-empty string
---@param value any Value to check
---@param name string Name for error message
function M.assert_string(value, name)
  assert(type(value) == "string" and value ~= "", string.format("%s must be a non-empty string", name))
end

--- Assert a table value
---@param value any Value to check
---@param name string Name for error message
function M.assert_table(value, name)
  assert(type(value) == "table", string.format("%s must be a table", name))
end

return M
