local branch = require("ergotu.util.worktrees.branch")
local commands = require("ergotu.util.worktrees.commands")
local jobs = require("ergotu.util.worktrees.jobs")
local paths = require("ergotu.util.worktrees.paths")
local switch = require("ergotu.util.worktrees.switch")
local ui = require("ergotu.util.worktrees.ui")

---@class ergotu.util.worktrees
local M = {}

function M.new_worktree()
  local branch_name = ui.get_user_input("Branch Name", { strip_spaces = true })
  if not branch_name then
    Util.warn("No branch name provided")
    return
  end

  local existing_branch = branch.exists(branch_name)
  local path = paths.get_worktree_path(branch_name)

  if not paths.validate_worktree_directory(path) then
    commands.build_add_args(branch_name, path, existing_branch, function(args)
      if not jobs.add_worktree(args) then
        return Util.warn("Could not create worktree")
      end
      switch.execute(path)
      commands.schedule_upstream_setup(existing_branch, branch_name)
    end)
  else
    switch.execute(path)
    commands.schedule_upstream_setup(existing_branch, branch_name)
  end
end

function M.switch_worktree()
  ui.select_worktree({
    prompt_prefix = "Select",
    empty_message = "No worktrees available",
    on_select = function(selection)
      switch.execute(selection.path)
    end,
  })
end

function M.remove_worktree()
  ui.select_worktree({
    prompt_prefix = "Remove",
    empty_message = "No worktrees available for removal",
    on_select = function(selection)
      if ui.show_confirmation(string.format("Remove worktree '%s'?", selection.path)) then
        if not jobs.remove_worktree(selection.path, false) then
          local force = ui.show_confirmation("Use --force?", { default = 2 })
          if not jobs.remove_worktree(selection.path, force) and force then
            Util.error("Could not remove worktree: " .. selection.path)
          end
        end
        Util.info("Removed worktree: " .. selection.path)
      end
    end,
  })
end

return setmetatable(M, {
  __index = function(t, k)
    t[k] = require("ergotu.util.worktrees." .. k)
    return t[k]
  end,
})
