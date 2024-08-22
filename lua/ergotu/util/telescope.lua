---@class ergotu.util.telescope

---@overload fun(command:string, opts?:ergotu.util.telescope.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class ergotu.util.telescope.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean
---@field follow? boolean

---@param builtin string
---@param opts ergotu.util.telescope.Opts
function M.open(builtin, opts)
  opts = opts or {}
  opts.follow = opts.follow ~= false
  if opts.cwd and opts.cwd ~= vim.uv.cwd() then
    local function open_cwd_dir()
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      M.open(
        builtin,
        vim.tbl_deep_extend("force", {}, opts or {}, {
          root = false,
          default_text = line,
        })
      )
    end
    ---@diagnostic disable-next-line: inject-field
    opts.attach_mappings = function(_, map)
      -- opts.desc is overridden by telescope, until it's changed there is this fix
      map("i", "<a-c>", open_cwd_dir, { desc = "Open cwd Directory" })
      return true
    end
  end

  require("telescope.builtin")[builtin](opts)
end

---@param command? string
---@param opts? ergotu.util.telescope.Opts
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    command = command ~= "auto" and command or "find_files"
    opts = opts or {}
    opts = vim.deepcopy(opts)

    if not opts.cwd and opts.root ~= false then
      opts.cwd = Util.root({ buf = opts.buf })
    end

    M.open(command, vim.deepcopy(opts))
  end
end

return M
