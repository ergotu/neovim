---@diagnostic disable: missing-fields
local Job = require("plenary.job")
local utils = require("ergotu.util.worktrees.utils")

local M = {}

local JobUtils = {
  run_job = function(args, error_msg, cwd, debug)
    local job = Job:new({
      command = "git",
      args = args,
      cwd = cwd or vim.uv.cwd(),
    })

    if debug and Snacks then
      _G.dd(job)
    end

    local output, code = job:sync()

    if code ~= 0 then
      Util.error(error_msg)
      return nil
    end

    return output
  end,
}

function M.is_bare()
  local output = JobUtils.run_job({
    "rev-parse",
    "--is-bare-repository",
  }, "Unable to check if repo is bare")
  return output and output[1]:lower():gsub("%s+", "") == "true"
end

function M.set_upstream(branch)
  return JobUtils.run_job({
    "branch",
    "--set-upstream-to=origin/" .. branch,
  }, nil)
end

function M.get_toplevel()
  local output = JobUtils.run_job({
    "rev-parse",
    "--show-toplevel",
  }, "Unable to get git toplevel")
  return output and output[1]
end

function M.get_worktrees()
  return JobUtils.run_job({
    "worktree",
    "list",
    "--porcelain",
  }, "Unable to get worktrees")
end

function M.add_worktree(args)
  return JobUtils.run_job(args, "Unable to add worktree")
end

function M.remove_worktree(path, force)
  local args = { "worktree", "remove" }
  if force then
    table.insert(args, "--force")
  end
  table.insert(args, path)

  return JobUtils.run_job(args, ("Failed to remove worktree: %s"):format(path))
end

function M.get_refs(patterns)
  patterns = patterns or { "refs/remotes/", "refs/tags/", "refs/heads/" }
  local args = { "for-each-ref", "--format=%(refname)", "--sort=-committerdate" }
  for _, pattern in ipairs(patterns) do
    table.insert(args, pattern)
  end
  return utils.map(JobUtils.run_job(args, "Unable to get refs"), function(ref)
    local name, _ = ref:gsub("^refs/[^/]*/", "")
    return name
  end)
end

function M.get_branches()
  return utils.merge(M.get_local_branches(), M.get_remote_branches())
end

function M.get_local_branches()
  return M.get_refs({ "refs/heads/" })
end

function M.get_remote_branches()
  return M.get_refs({ "refs/remotes/" })
end

function M.get_tags()
  return M.get_refs({ "refs/tags/" })
end

return M
