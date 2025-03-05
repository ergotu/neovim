local jobs = require("ergotu.util.worktrees.jobs")

local M = {}

local function get_toplevel_parent()
  local toplevel = jobs.get_toplevel()
  if not toplevel then
    return nil
  end
  return vim.fs.normalize(toplevel .. "/..")
end

local function validate_toplevel(toplevel)
  if not toplevel then
    Util.warn("Could not determine repository root path")
    return false
  end
  return true
end

function M.get_worktree_path(branch)
  local is_bare = jobs.is_bare()
  local base_path = is_bare and "." or get_toplevel_parent()

  if not is_bare and not validate_toplevel(base_path) then
    return nil
  end

  local full_path = base_path .. "/" .. branch
  return vim.fs.normalize(full_path)
end

function M.validate_worktree_directory(path)
  if vim.fn.isdirectory(path) == 1 then
    Util.warn(("Worktree directory already exists: %s"):format(path))
    return true
  end
  return false
end

return M
