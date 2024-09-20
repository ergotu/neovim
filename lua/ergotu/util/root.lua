---@class ergotu.util.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m)
    return m.get()
  end,
})

-- Default specification for root detection
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Cache to store detected roots per buffer
M.cache = {}

---@return string
function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

-- Helper function to check if a file or directory exists
---@param path string
---@return boolean
local function exists(path)
  return vim.fn.empty(vim.fn.glob(path)) == 0
end

--- Get the real path of a buffer
---@param buf number
---@return string|nil
function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

--- Get the current working directory
---@return string
function M.cwd()
  return M.realpath(vim.uv.cwd()) or ""
end

--- Get the real path of a given path
---@param path string|nil
---@return string|nil
function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.uv.fs_realpath(path) or path
  return Util.norm(path)
end

-- Built-in detector functions
M.detectors = {
  --- Detect root using LSP
  ---@param buf number
  ---@return string|nil
  lsp = function(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf })
    if next(clients) == nil then
      return nil
    end
    return vim.fn.getcwd()
  end,

  --- Detect root using current working directory
  ---@param _ number
  ---@return string
  cwd = function(_)
    return vim.fn.getcwd()
  end,

  --- Detect root using patterns
  ---@param buf number
  ---@param patterns string[]
  ---@return string|nil
  pattern = function(buf, patterns)
    local path = vim.fn.expand("%:p:h", buf)
    while path and path ~= "/" do
      for _, pattern in ipairs(patterns) do
        if exists(vim.fn.join({ path, pattern }, "/")) then
          return path
        end
      end
      path = vim.fn.fnamemodify(path, ":h")
    end
    return nil
  end,
}

-- Function to detect the roots of a project
--- @param opts? { buf?: number, all?: boolean }
--- @return string[]
function M.detect(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local detectors = vim.g.root or M.spec
  local roots = {}

  for _, detector in ipairs(detectors) do
    local root
    if type(detector) == "string" then
      if M.detectors[detector] then
        root = M.detectors[detector](buf)
      elseif vim.fn.exists(detector) == 1 then
        root = vim.fn[detector](buf)
      end
    elseif type(detector) == "table" then
      root = M.detectors.pattern(buf, detector)
    elseif type(detector) == "function" then
      local result = detector(buf)
      if type(result) == "string" then
        root = result
      elseif type(result) == "table" then
        for _, path in ipairs(result) do
          if exists(path) then
            root = path
            break
          end
        end
      end
    end

    if root then
      table.insert(roots, root)
      if not opts.all then
        break
      end
    end
  end

  return roots
end

-- Main function to find the root of a project
--- @param opts? {normalize?: boolean, buf?: number, all?: boolean}
--- @return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local root = M.cache[buf]
  if not root then
    local roots = M.detect({ buf = buf, all = false })
    root = roots[1] or vim.uv.cwd()
    M.cache[buf] = root
  end

  if root and opts.normalize then
    root = vim.fn.fnamemodify(root, ":p")
  end

  return Util.is_win() and root:gsub("/", "\\") or root
end

-- Clear cache function
--- @param buf? number
function M.clear_cache(buf)
  if buf then
    M.cache[buf] = nil
  else
    M.cache = {}
  end
end

-- Setup function to create user command and autocommands
function M.setup()
  vim.api.nvim_create_user_command("Root", function()
    print("Current root: " .. M.get())
  end, { desc = "Show the root for the current buffer" })

  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("lazyvim_root_cache", { clear = true }),
    callback = function(event)
      M.clear_cache(event.buf)
    end,
  })
end

return M
