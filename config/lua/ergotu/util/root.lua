---@class ergotu.util.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

---@type table<number, string> Per-buffer cache of root directories
M.cache = {}

---@type string[] Root detection patterns
M.spec = { ".jj", ".git", "lua", "package.json", "Cargo.toml", "pyproject.toml" }

--- Detect root directory using LSP workspace folders
---@param buf? number Buffer number (default: current buffer)
---@return string|nil Root directory from LSP or nil
function M.detect_lsp(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in ipairs(clients) do
    -- Try workspace folders first (multi-root workspace support)
    if client.workspace_folders then
      for _, folder in ipairs(client.workspace_folders) do
        if folder.name then
          return folder.name
        end
      end
    end

    -- Fall back to root_dir from config
    if client.config and client.config.root_dir then
      return client.config.root_dir
    end
  end

  return nil
end

--- Detect root directory using pattern matching
---@param buf? number Buffer number (default: current buffer)
---@return string|nil Root directory from patterns or nil
function M.detect_pattern(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  return vim.fs.root(buf, M.spec)
end

--- Detect root directory using all available methods
---@param buf? number Buffer number (default: current buffer)
---@return string Root directory (guaranteed non-nil, falls back to cwd)
function M.detect(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  -- Try LSP detection first
  local lsp_root = M.detect_lsp(buf)
  if lsp_root then
    return lsp_root
  end

  -- Try pattern-based detection
  local pattern_root = M.detect_pattern(buf)
  if pattern_root then
    return pattern_root
  end

  -- Fall back to current working directory
  return vim.fn.getcwd()
end

--- Get cached root directory for buffer (with automatic caching)
---@param opts? {buf?: number, force?: boolean} Options
---@return string Root directory (guaranteed non-nil)
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()

  -- Force re-detection if requested
  if opts.force then
    M.cache[buf] = nil
  end

  -- Return cached value if available
  if M.cache[buf] then
    return M.cache[buf]
  end

  -- Detect and cache
  local root = M.detect(buf)
  M.cache[buf] = root
  return root
end

--- Clear cache for specific buffer or all buffers
---@param buf? number Buffer number (nil = clear all)
function M.clear_cache(buf)
  if buf then
    M.cache[buf] = nil
  else
    M.cache = {}
  end
end

--- Display root detection information for current buffer
---@param buf? number Buffer number (default: current buffer)
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  local lines = {}

  -- Header
  table.insert(lines, "# Root Detection Info")
  table.insert(lines, "")

  -- Current buffer path
  local bufname = vim.api.nvim_buf_get_name(buf)
  if bufname ~= "" then
    table.insert(lines, string.format("**Buffer:** `%s`", bufname))
  else
    table.insert(lines, "**Buffer:** *[No Name]*")
  end
  table.insert(lines, "")

  -- Cached root (if exists)
  local cached_root = M.cache[buf]
  if cached_root then
    table.insert(lines, string.format("**[x] Cached Root:** `%s`", cached_root))
  else
    table.insert(lines, "**Cached Root:** *None (will detect on next access)*")
  end
  table.insert(lines, "")

  -- LSP Detection
  table.insert(lines, "## LSP Detection")
  local lsp_root = M.detect_lsp(buf)
  local clients = vim.lsp.get_clients({ bufnr = buf })

  if #clients > 0 then
    table.insert(lines, string.format("**Result:** `%s`", lsp_root or "*None*"))
    table.insert(lines, "")
    table.insert(lines, "**Active LSP Clients:**")
    for _, client in ipairs(clients) do
      local client_root = "unknown"
      if client.config and client.config.root_dir then
        client_root = client.config.root_dir
      elseif client.workspace_folders and client.workspace_folders[1] then
        client_root = client.workspace_folders[1].name
      end
      table.insert(lines, string.format("- `%s`: `%s`", client.name, client_root))
    end
  else
    table.insert(lines, "*No LSP clients attached*")
  end
  table.insert(lines, "")

  -- Pattern Detection
  table.insert(lines, "## Pattern Detection")
  local pattern_root = M.detect_pattern(buf)
  if pattern_root then
    table.insert(lines, string.format("**Result:** `%s`", pattern_root))
    table.insert(lines, "")
    table.insert(lines, "**Patterns searched:**")
    for _, pattern in ipairs(M.spec) do
      table.insert(lines, string.format("- `%s`", pattern))
    end
  else
    table.insert(lines, "*No pattern match found*")
  end
  table.insert(lines, "")

  -- Current working directory
  table.insert(lines, "## Fallback")
  table.insert(lines, string.format("**CWD:** `%s`", vim.fn.getcwd()))
  table.insert(lines, "")

  -- Final result
  local final_root = M.get({ buf = buf })
  table.insert(lines, "---")
  table.insert(lines, "")
  table.insert(lines, string.format("**Final Root:** `%s`", final_root))

  -- Use vim.notify (which Snacks will override if loaded)
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Root Detection" })
end

--- Setup autocmds for automatic cache invalidation
function M.setup()
  local group = vim.api.nvim_create_augroup("ergovim_root", { clear = true })

  -- Invalidate cache on relevant events
  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
    group = group,
    callback = function(event)
      M.clear_cache(event.buf)
    end,
    desc = "Clear root cache on LSP attach/detach",
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    callback = function(event)
      -- Clear cache when new root markers might be created
      local filename = vim.fn.fnamemodify(event.file, ":t")
      for _, pattern in ipairs(M.spec) do
        if filename == pattern then
          M.clear_cache()
          break
        end
      end
    end,
    desc = "Clear root cache when root markers are created",
  })

  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      M.clear_cache()
    end,
    desc = "Clear root cache on directory change",
  })

  -- Clean up cache for deleted buffers
  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    group = group,
    callback = function(event)
      M.cache[event.buf] = nil
    end,
    desc = "Clean up root cache for deleted buffer",
  })

  -- Create user command
  vim.api.nvim_create_user_command("RootInfo", function()
    M.info()
  end, {
    desc = "Display root detection information",
  })
end

return M
