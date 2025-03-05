local M = {}

function M.execute(path)
  if not path then
    return
  end
  if path == vim.uv.cwd() then
    return Util.warn("Already in the requested worktree")
  end

  vim.schedule(function()
    vim.cmd("cd " .. path)
    vim.cmd("clearjumps")
    Util.info("Switched to worktree: " .. path)
  end)
end

return M
