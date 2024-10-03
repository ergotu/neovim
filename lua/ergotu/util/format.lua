---@class ergotu.util.format
---@overload fun(opts?: {force?:boolean})
local M = {}

---@param buf? number
function M.enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat

  -- If the buffer has a local value, use that
  if baf ~= nil then
    return baf
  end

  -- Otherwise use the global value if set, or true by default
  return gaf == nil or gaf
end

function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local enabled = M.enabled(buf)
  local lines = {
    "# Status",
    ("= [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("= [%s] buffer **%s**"):format(
      enabled and "x" or " ",
      baf == nil and "inherit" or baf and "enabled" or "disabled"
    ),
    "",
  }
  local conform_success, conform = pcall(require, "conform")
  local have
  if conform_success then
    for _, formatter in pairs(conform.list_formatters_for_buffer(buf)) do
      if #formatter > 0 then
        have = true
        local formatterInfo = conform.get_formatter_info(formatter, buf)
        lines[#lines + 1] = ("- [%s] **%s** "):format(formatterInfo.available and "x" or " ", formatterInfo.name)
      end
    end
    if not have then
      lines[#lines + 1] = "\n***No formatters available for this buffer.***"
    end
  end
  Util[enabled and "info" or "warn"](
    table.concat(lines, "\n"),
    { title = "Format (" .. (enabled and "enabled" or "disabled") .. ")" }
  )
end

function M.setup()
  vim.api.nvim_create_user_command("FormatInfo", function()
    M.info()
  end, { desc = "Show info about the formatters for the current buffer" })
end

return M
