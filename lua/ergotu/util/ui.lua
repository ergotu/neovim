---@class ergotu.util.ui
local M = {}

function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    local filetype = vim.bo[buf].filetype

    -- If we dont have a filetype, don't check for treesitter
    if filetype == "" then
      return "0"
    end

    -- if we are in a neogit filetype
    if filetype:find("Neogit") then
      return "0"
    end
    vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr()
end

---@return {fg?:string}?
function M.fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local fg = hl and hl.fg or hl.foreground
  return fg and { fg = string.format("#%06x", fg) } or nil
end

return M
