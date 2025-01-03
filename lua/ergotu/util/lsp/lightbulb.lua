--- Implementation inspired from https://github.com/nvimdev/lspsaga.nvim/blob/a751b92b5d765a99fe3a42b9e51c046f81385e15/lua/lspsaga/codeaction/lightbulb.lua
---@class ergotu.util.lsp.lightbulb
local M = {}

local lb_name = "lightbulb"
local lb_namespace = vim.api.nvim_create_namespace(lb_name)
local lb_sign_name = "LightBulbSign"
local lb_group = vim.api.nvim_create_augroup(lb_name, {})
local code_action_method = vim.lsp.protocol.Methods.textDocument_codeAction

local timer = vim.uv.new_timer()
assert(timer, "Timer was not initialized")

local updated_bufnr = nil

-- Configuration for display method
M.config = {
  use_sign_column = true,
  update_delay = vim.o.updatetime,
  icon = Util.config.icons.diagnostics.Hint,
  highlight_group = "DiagnosticSignHint",
}

-- Define the sign only once
if not vim.fn.sign_getdefined(lb_sign_name)[1] then
  vim.fn.sign_define(lb_sign_name, { text = M.config.icon, texthl = M.config.highlight_group })
end

--- Updates the current lightbulb.
---@param bufnr number?
---@param line number?
local function update_lightbulb(bufnr, line)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  -- Clear existing extmarks and signs
  vim.api.nvim_buf_clear_namespace(bufnr, lb_namespace, 0, -1)
  vim.fn.sign_unplace(lb_name, { buffer = bufnr })

  -- Extra check in case autocommand fails
  if not line or vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return
  end

  if M.config.use_sign_column then
    -- Place the sign at the specified line
    pcall(vim.fn.sign_place, 0, lb_name, lb_sign_name, bufnr, {
      lnum = line + 1,
      priority = 100,
    })
  else
    -- Use extmark to place the lightbulb at the end of the line
    pcall(vim.api.nvim_buf_set_extmark, bufnr, lb_namespace, line, -1, {
      virt_text = { { " " .. M.config.icon, M.config.highlight_group } },
      hl_mode = "combine",
    })
  end

  updated_bufnr = bufnr
end

--- Queries the LSP servers for code actions and updates the lightbulb
--- accordingly.
---@param bufnr number
---@param client vim.lsp.Client
local function render(bufnr, client)
  local winnr = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(winnr) ~= bufnr then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  ---@type lsp.CodeActionParams
  local params = vim.lsp.util.make_range_params(winnr, client.offset_encoding)
  params.context = {
    diagnostics = diagnostics,
    triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic,
  }

  vim.lsp.buf_request(bufnr, code_action_method, params, function(_, res, _)
    if vim.api.nvim_get_current_buf() ~= bufnr then
      return
    end

    update_lightbulb(bufnr, (res and #res > 0 and line) or nil)
  end)
end

---@param bufnr number
---@param client vim.lsp.Client
local function update(bufnr, client)
  timer:stop()

  -- Remove existing extmarks/signs without waiting for the timer
  -- This makes the user experience snappier
  update_lightbulb(updated_bufnr)

  if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
    return
  end

  -- Only run the render function if the cursor has not moved for 100ms
  -- This is to prevent spamming the LSP if the cursor is moving quickly
  timer:start(M.config.update_delay, 0, function()
    timer:stop()
    vim.schedule(function()
      -- Check if the buffer is still valid
      if vim.api.nvim_buf_is_valid(bufnr) then
        render(bufnr, client)
      end
    end)
  end)
end

--- Configures autocommands to update the code action lightbulb.
---@param bufnr integer
---@param client_id integer
M.on_attach = function(bufnr, client_id)
  local client = vim.lsp.get_client_by_id(client_id)

  if not client or not client:supports_method(code_action_method) then
    return
  end

  local buf_group_name = lb_name .. tostring(bufnr)
  if pcall(vim.api.nvim_get_autocmds, { group = buf_group_name, buffer = bufnr }) then
    return
  end

  local lb_buf_group = vim.api.nvim_create_augroup(buf_group_name, { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = lb_buf_group,
    desc = "Update lightbulb when moving the cursor in normal/visual mode",
    buffer = bufnr,
    callback = function()
      update(bufnr, client)
    end,
  })

  vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave" }, {
    group = lb_buf_group,
    desc = "Update lightbulb when entering insert mode or leaving the buffer",
    buffer = bufnr,
    callback = function()
      update_lightbulb(bufnr, nil)
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = lb_group,
    desc = "Detach code action lightbulb",
    buffer = bufnr,
    callback = function()
      update_lightbulb(bufnr)
      pcall(vim.api.nvim_del_augroup_by_name, lb_name .. tostring(bufnr))
    end,
  })
end

return M
