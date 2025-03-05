local jobs = require("ergotu.util.worktrees.jobs")

local M = {}

function M.exists(branch)
  local branches = jobs.get_branches()
  return branches and vim.tbl_contains(branches, branch) or false
end

return M
