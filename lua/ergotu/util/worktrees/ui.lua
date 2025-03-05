local jobs = require("ergotu.util.worktrees.jobs")
local parser = require("ergotu.util.worktrees.parser")
local utils = require("ergotu.util.worktrees.utils")
local M = {}

---@class SelectorConfig
---@field get_items fun(): any[] # Function returning items for selection
---@field default_empty string # Default message when no items available
---@field prompt_suffix string # Text to append to prompt
---@field formatter fun(item: any): string # Function to format display items

---@class SelectorOptions
---@field empty_message? string # Custom empty message override
---@field prompt_prefix? string # Text to prepend to prompt
---@field on_select fun(selection: any) # Callback for selected item
---@field on_cancel? fun() # Callback when selection is canceled

---Create a selector UI component
---@param config SelectorConfig
---@return fun(opts: SelectorOptions) # selector function
local function create_selector(config)
  return function(opts)
    local items = config.get_items()
    if not items or #items == 0 then
      Util.warn(opts.empty_message or config.default_empty)
      if opts.on_cancel then
        opts.on_cancel()
      end
      return
    end

    vim.ui.select(items, {
      prompt = (opts.prompt_prefix or "") .. config.prompt_suffix,
      format_item = config.formatter,
    }, function(selection)
      if selection then
        if opts.on_select then
          opts.on_select(selection)
        end
      else
        if opts.on_cancel then
          opts.on_cancel()
        end
      end
    end)
  end
end

---@type fun(opts: SelectorOptions)
---Dialog for selecting a worktree from available options
M.select_worktree = create_selector({
  get_items = parser.get_worktrees,
  default_empty = "No worktrees available",
  prompt_suffix = " worktree:",
  formatter = function(worktree)
    return string.format("%s (%s)", worktree.folder, worktree.branch or "detached")
  end,
})

---@type fun(opts: SelectorOptions)
---Dialog for selecting a git reference
M.select_ref = create_selector({
  get_items = function()
    return utils.merge(jobs.get_branches(), jobs.get_tags())
  end,
  default_empty = "No references available",
  prompt_suffix = " reference:",
  formatter = function(ref)
    return ref:gsub("^refs/[^/]*/", "")
  end,
})

---@type fun(opts: SelectorOptions)
---Dialog for selecting a branch from available options
M.select_branch = create_selector({
  get_items = jobs.get_branches,
  default_empty = "No branches available",
  prompt_suffix = " branch:",
  formatter = function(branch)
    return branch
  end,
})

---@class ConfirmationOpts
---@field values? string[]
---@field default? integer
---@field ok_value? integer

---Show a confirmation dialog
---@param msg string # Message to display in dialog
---@param options? ConfirmationOpts
---@return boolean # true if user confirmed, false otherwise
function M.show_confirmation(msg, options)
  options = vim.tbl_extend("force", {
    values = { "&Yes", "&No" },
    default = 1,
    ok_value = 1,
  }, options or {})

  return vim.fn.confirm(msg, table.concat(options.values, "\n"), options.default) == options.ok_value
end

---@class GetUserInputOpts
---@field strip_spaces boolean? Replace spaces with dashes
---@field default any? Default value
---@field completion string?
---@field separator string?
---@field cancel string?
---@field prepend string?

---@param prompt string Prompt to use for user input
---@param opts GetUserInputOpts? Options table
---@return string|nil
function M.get_user_input(prompt, opts)
  opts = vim.tbl_extend("keep", opts or {}, { strip_spaces = false, separator = ": " })

  vim.fn.inputsave()

  if opts.prepend then
    vim.defer_fn(function()
      vim.api.nvim_input(opts.prepend)
    end, 10)
  end

  local status, result = pcall(vim.fn.input, {
    prompt = ("%s%s"):format(prompt, opts.separator),
    default = opts.default,
    completion = opts.completion,
    cancelreturn = opts.cancel,
  })

  vim.fn.inputrestore()
  if not status then
    return nil
  end

  if opts.strip_spaces then
    result, _ = result:gsub("%s", "-")
  end

  if result == "" then
    return nil
  end

  return result
end

return M
