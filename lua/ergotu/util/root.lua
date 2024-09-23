---@class ergotu.util.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m)
    return m.get()
  end,
})

-- Default specification for root detection
M.spec = { "lsp", "vcs", { ".git", "lua" }, "cwd" }

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
  return M.realpath(vim.loop.cwd()) or ""
end

--- Get the real path of a given path
---@param path string|nil
---@return string|nil
function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.loop.fs_realpath(path) or path
  return Util.norm(path)
end

-- Built-in detector functions
M.detectors = {
  --- Detect root using LSP
  ---@param buf number
  ---@return table[]|nil
  lsp = function(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf })
    local details = {}
    for _, client in ipairs(clients) do
      if client.config.root_dir then
        table.insert(details, { name = client.name, root = client.config.root_dir })
      end
    end
    return #details > 0 and details or nil
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

  --- Detect root using VCS directories
  ---@param buf number
  ---@return string|nil
  vcs = function(buf)
    local path = vim.fn.expand("%:p:h", buf)
    while path and path ~= "/" do
      if
        exists(vim.fn.join({ path, ".git" }, "/"))
        or exists(vim.fn.join({ path, ".hg" }, "/"))
        or exists(vim.fn.join({ path, ".svn" }, "/"))
      then
        return path
      end
      path = vim.fn.fnamemodify(path, ":h")
    end
    return nil
  end,
}

-- Function to detect the roots of a project
--- @param opts? { buf?: number, all?: boolean }
--- @return table
function M.detect(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local detectors = vim.g.root or M.spec
  local roots = {}
  local details = {}

  for _, detector in ipairs(detectors) do
    local result
    local detail = { detector = detector, result = nil }
    if type(detector) == "string" then
      if M.detectors[detector] then
        result = M.detectors[detector](buf)
        detail.result = result
      elseif vim.fn.exists(detector) == 1 then
        result = vim.fn[detector](buf)
        detail.result = result
      end
    elseif type(detector) == "table" then
      result = M.detectors.pattern(buf, detector)
      detail.result = result
    elseif type(detector) == "function" then
      local res = detector(buf)
      if type(res) == "string" then
        result = res
        detail.result = res
      elseif type(res) == "table" then
        for _, path in ipairs(res) do
          if exists(path) then
            result = path
            detail.result = path
            break
          end
        end
      end
    end

    table.insert(details, detail)

    if result then
      if type(result) == "table" then
        vim.list_extend(roots, result)
      else
        table.insert(roots, result)
      end
      if not opts.all then
        break
      end
    end
  end

  return { roots = roots, details = details }
end

-- Main function to find the root of a project
--- @param opts? {normalize?: boolean, buf?: number, all?: boolean}
--- @return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local root = M.cache[buf]

  if not root then
    local result = M.detect({ buf = buf, all = false })
    local roots = result.roots

    -- Extract the first valid root path, handling nested tables
    if type(roots) == "table" then
      for _, item in ipairs(roots) do
        if type(item) == "string" then
          root = item
          break
        elseif type(item) == "table" and item.root then
          root = item.root
          break
        end
      end
    end

    -- Fallback to current working directory if no valid root is found
    root = root or vim.uv.cwd()
    M.cache[buf] = root
  end

  if type(root) ~= "string" then
    error("Root is not a string: " .. tostring(root))
  end

  if root and opts.normalize then
    return root
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
    Util.info("Current root: " .. M.get(), { title = "Root Finder" })
  end, { desc = "Show the root for the current buffer" })

  vim.api.nvim_create_user_command("RootInfo", function()
    local buf = vim.api.nvim_get_current_buf()
    local result = M.detect({ buf = buf, all = true })
    local details = result.details
    local lines = { "Root Detection Info:" }
    for _, detail in ipairs(details) do
      local detector = type(detail.detector) == "table" and vim.inspect(detail.detector) or tostring(detail.detector)
      local result = detail.result or "nil"
      if detector == "lsp" and type(result) == "table" then
        for _, lsp_detail in ipairs(result) do
          table.insert(lines, string.format("LSP: %s, Root: %s", lsp_detail.name, lsp_detail.root))
        end
      else
        table.insert(lines, string.format("Detector: %s, Result: %s", detector, result))
      end
    end
    Util.info(table.concat(lines, "\n"), { title = "Root Detection Info" })
  end, { desc = "Show details of all root detectors" })

  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("lazyvim_root_cache", { clear = true }),
    callback = function(event)
      M.clear_cache(event.buf)
    end,
  })
end

return M
