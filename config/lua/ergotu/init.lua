_G.Ergovim = require("ergotu.util")

-- Get the directory where this file is located
local source = debug.getinfo(1, "S").source
local init_path = source:sub(2) -- Remove the '@' prefix
local ergotu_dir = vim.fn.fnamemodify(init_path, ":h")

-- Helper to format error messages with context
local function format_error(module_name, err, category)
  local error_parts = {
    string.format("Failed to load %s", module_name),
    string.format("  Error: %s", tostring(err)),
  }

  -- Add context-specific suggestions
  if tostring(err):match("module '.*' not found") then
    table.insert(error_parts, "  Suggestion: Check if plugin is added to flake.nix under plugins.opt")
  elseif tostring(err):match("attempt to index") or tostring(err):match("attempt to call") then
    table.insert(error_parts, "  Suggestion: Check for nil values or missing dependencies")
  elseif tostring(err):match("syntax error") then
    table.insert(error_parts, "  Suggestion: Check Lua syntax in the module file")
  end

  table.insert(error_parts, string.format("  Category: %s", category))

  return table.concat(error_parts, "\n")
end

-- Helper to classify error severity
local function get_error_level(category, err)
  -- Critical categories
  if category == "lsp" or category == "language configs" then
    return vim.log.levels.ERROR
  end

  -- Missing dependencies are warnings
  if tostring(err):match("module '.*' not found") then
    return vim.log.levels.WARN
  end

  -- Syntax/runtime errors are errors
  if tostring(err):match("syntax error") or tostring(err):match("attempt to") then
    return vim.log.levels.ERROR
  end

  return vim.log.levels.WARN
end

---@param dir string Directory path relative to ergotu dir
---@param module_prefix string Module prefix for requires (e.g., "ergotu.lang", "ergotu.plugins.lsp")
---@param category_name string Name for debug logging
---@return lz.n.Spec[] specs
---@return table errors Table of errors encountered
local function load_modules(dir, module_prefix, category_name)
  local category_specs = {}
  local load_errors = {}
  local category_path = ergotu_dir .. "/" .. dir

  -- Use fs_scandir instead of glob for better performance
  local files = {}
  local handle, err = vim.uv.fs_scandir(category_path)
  if not handle then
    vim.notify(
      string.format("Failed to scan directory %s: %s", category_path, err or "unknown error"),
      vim.log.levels.ERROR
    )
    return {}, {}
  end

  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    -- Only process .lua files, skip init.lua
    if type == "file" and name:match("%.lua$") and name ~= "init.lua" then
      local filename = name:match("^(.+)%.lua$") -- Remove .lua extension
      table.insert(files, filename)
    end
  end

  for _, filename in ipairs(files) do
    -- Skip init.lua files (redundant check, but keeping for safety)
    if filename ~= "init" then
      local module_name = module_prefix .. "." .. filename
      local ok, module = pcall(require, module_name)

      if ok then
        if type(module) == "table" and #module > 0 then
          -- If module returns a table, merge it
          vim.list_extend(category_specs, module)
        end
        -- Module loaded but didn't return specs (e.g., lang files that only call add_*())
      else
        -- Collect error for summary
        table.insert(load_errors, {
          module = module_name,
          error = module,
          category = category_name,
        })

        local error_msg = format_error(module_name, module, category_name)
        local level = get_error_level(category_name, module)
        vim.notify(error_msg, level)
      end
    end
  end

  return category_specs, load_errors
end

-- Load plugin specs
---@type lz.n.Spec[]
local specs = {}
local all_errors = {}

-- Load language configs first (they populate config registries)
local lang_specs, lang_errors = load_modules("lang", "ergotu.lang", "language configs")
vim.list_extend(specs, lang_specs)
vim.list_extend(all_errors, lang_errors)

-- Load plugin categories
local categories = {
  "coding",
  "colorscheme",
  "dap",
  "editor",
  "formatting",
  "linting",
  "lsp",
  "testing",
  "treesitter",
  "ui",
  "util",
}

for _, category in ipairs(categories) do
  local category_specs, category_errors = load_modules("plugins/" .. category, "ergotu.plugins." .. category, category)
  vim.list_extend(specs, category_specs)
  vim.list_extend(all_errors, category_errors)
end

-- Show error summary if any modules failed to load
if #all_errors > 0 then
  local error_summary = { string.format("Failed to load %d modules:", #all_errors) }
  for _, err in ipairs(all_errors) do
    table.insert(error_summary, string.format("  - %s", err.module))
  end
  table.insert(error_summary, "Check notifications above for details")
  vim.notify(table.concat(error_summary, "\n"), vim.log.levels.WARN)
end

require("ergotu.config.opts")
require("ergotu.config.autocmds")

-- Setup root detection utility
Ergovim.root.setup()

local notifs = {}
local function temp(...)
  table.insert(notifs, vim.F.pack_len(...))
end

local orig = vim.notify
vim.notify = temp

local timer = vim.uv.new_timer()
if not timer then
  -- If timer creation fails, restore original notify and replay immediately
  vim.notify = orig
  for _, notif in ipairs(notifs) do
    pcall(function()
      orig(vim.F.unpack_len(notif))
    end)
  end
  orig("Warning: Failed to create notification buffer timer", vim.log.levels.WARN)
  return
end
local check = assert(vim.uv.new_check())

local replay = function()
  timer:stop()
  check:stop()
  if vim.notify == temp then
    vim.notify = orig -- put back the original notify if needed
  end
  vim.schedule(function()
    ---@diagnostic disable-next-line: no-unknown
    for _, notif in ipairs(notifs) do
      local ok, err = pcall(function()
        vim.notify(vim.F.unpack_len(notif))
      end)
      if not ok then
        orig(string.format("Failed to replay notification: %s", tostring(err)), vim.log.levels.ERROR)
      end
    end
  end)
end

-- wait till vim.notify has been replaced (check if Snacks is loaded)
check:start(function()
  if package.loaded["snacks"] and vim.notify ~= temp then
    replay()
  end
end)
-- or if it took more than 2000ms, then something went wrong
timer:start(2000, 0, function()
  replay()
  if not package.loaded["snacks"] then
    vim.notify("Warning: Snacks notifier not loaded in time, using fallback", vim.log.levels.WARN)
  end
end)

require("ergotu.config.snacks").setup()
require("flatten").setup({
  hooks = {
    post_open = function(opts)
      local bufnr, winnr, ft, is_blocking, is_diff =
        opts.bufnr, opts.winnr, opts.filetype, opts.is_blocking, opts.is_diff

      if is_blocking then
        Snacks.terminal.toggle()
      elseif not is_diff then
        vim.api.nvim_set_current_win(winnr)
      end

      if ft == "gitcommit" or ft == "gitrebase" or ft == "jjdescription" then
        local version = vim.api.nvim_buf_get_changedtick(bufnr)

        vim.api.nvim_create_autocmd("BufWritePost", {
          buffer = bufnr,
          callback = vim.schedule_wrap(function()
            if vim.api.nvim_buf_get_changedtick(bufnr) == version then
              return
            end
            Snacks.bufdelete.delete(bufnr)
          end),
        })
      end
    end,
    block_end = vim.schedule_wrap(function(_)
      Snacks.terminal.toggle()
    end),
  },
})

LZN = require("lz.n")

LZN.register_handler(require("handlers.which-key"))

-- Load all plugin specs with lz.n
LZN.load(specs)

require("ergotu.health").loaded = true
require("ergotu.config.keymaps")

vim.cmd.colorscheme("catppuccin")

require("lzn-auto-require").enable()
