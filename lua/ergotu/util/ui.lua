---@class ergotu.util.ui
local M = {}

---@return {fg?:string}?
function M.fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local fg = hl and hl.fg or hl.foreground
  return fg and { fg = string.format("#%06x", fg) } or nil
end

M.skip_foldexpr = {} ---@type table<number,boolean>
local skip_check = assert(vim.uv.new_check())

function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  -- disable folding if there are no treesitter highlights
  if not vim.b[buf].ts_highlight then
    return "0"
  end

  -- still in the same tick and no parser
  if M.skip_foldexpr[buf] then
    return "0"
  end

  -- don't use treesitter folds for non-file buffers
  if vim.bo[buf].buftype ~= "" then
    return "0"
  end

  -- as long as we don't have a filetype, don't bother
  -- checking if treesitter is available (it won't)
  if vim.bo[buf].filetype == "" then
    return "0"
  end

  local ok = pcall(vim.treesitter.get_parser, buf)

  if ok then
    return vim.treesitter.foldexpr()
  end

  -- no parser available, so mark it as skip
  -- in the next tick, all skip marks will be reset
  M.skip_foldexpr[buf] = true
  skip_check:start(function()
    M.skip_foldexpr = {}
    skip_check:stop()
  end)
  return "0"
end

function M.maximize()
  ---@type {k:string, v:any}[]?
  local maximized = nil
  return Snacks.toggle({
    name = "Maximize",
    get = function()
      return maximized ~= nil
    end,
    set = function(state)
      if state then
        maximized = {}
        local function set(k, v)
          table.insert(maximized, 1, { k = k, v = vim.o[k] })
          vim.o[k] = v
        end
        set("winwidth", 999)
        set("winheight", 999)
        set("winminwidth", 10)
        set("winminheight", 4)
        vim.cmd("wincmd =")
        -- `QuitPre` seems to be executed even if we quit a normal window, so we don't want that
        -- `VimLeavePre` might be another consideration? Not sure about differences between the 2
        vim.api.nvim_create_autocmd("ExitPre", {
          once = true,
          group = vim.api.nvim_create_augroup("lazyvim_restore_max_exit_pre", { clear = true }),
          desc = "Restore width/height when close Neovim while maximized",
          callback = function()
            M.maximize.set(false)
          end,
        })
      else
        for _, opt in ipairs(maximized) do
          vim.o[opt.k] = opt.v
        end
        maximized = nil
        vim.cmd("wincmd =")
      end
    end,
  })
end

return M
