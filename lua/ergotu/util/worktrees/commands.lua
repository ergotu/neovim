local jobs = require("ergotu.util.worktrees.jobs")
local ui = require("ergotu.util.worktrees.ui")

local M = {}

function M.build_add_args(branch, path, is_existing, on_args)
  local args = { "worktree", "add" }

  if is_existing then
    return on_args(vim.list_extend(args, { path, branch }))
  end

  table.insert(args, "-b")
  table.insert(args, branch)
  table.insert(args, path)

  ui.select_ref({
    prompt_prefix = "Base",
    on_select = function(selected)
      if selected and not selected:match("^HEAD") then
        table.insert(args, selected)
      end
      on_args(args)
    end,
  })
end

function M.schedule_upstream_setup(needs_setup, branch)
  if needs_setup then
    vim.schedule(function()
      jobs.set_upstream(branch)
    end)
  end
end

return M
