---@class ergotu.util.lualine.jj
local M = {}

local uv = vim.uv or vim.loop

-- root -> { change_id = "", desc = "", indicators = "", running=false, last=0 }
local cache = {}

-- debounce (ms) for clustered events
local DEBOUNCE_MS = 300

local function trim(s)
  return (s or ""):gsub("%s+$", "")
end

local function shorten(s, max)
  s = s or ""
  if #s <= max then
    return s
  end
  return s:sub(1, max - 1) .. "…"
end

local function buf_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return uv.cwd()
  end
  return vim.fs.dirname(name)
end

local function is_normal_file_buf(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end
  return true
end

local function find_jj_root_for_buf(bufnr)
  local dir = buf_dir(bufnr)
  local found = vim.fs.find(".jj", { path = dir, upward = true, type = "directory" })[1]
  if not found then
    return nil
  end
  return vim.fs.dirname(found)
end

local function ensure_root_state(root)
  if not cache[root] then
    cache[root] = { change_id = "", desc = "", indicators = "", running = false, last = 0 }
  end
  return cache[root]
end

---Get cached root for a buffer; compute once and store in vim.b.jj_root.
---Stores "" when not in a jj repo to avoid repeated upward searches.
---@param bufnr integer
---@return string|nil root nil means "not a normal file buffer"; "" means "checked, not in repo"; otherwise a path
function M.buf_root(bufnr)
  if not is_normal_file_buf(bufnr) then
    return nil
  end

  -- buffer-local cache
  if vim.b[bufnr].jj_root ~= nil then
    return vim.b[bufnr].jj_root
  end

  local root = find_jj_root_for_buf(bufnr) or ""
  vim.b[bufnr].jj_root = root
  return root
end

function M.in_repo()
  local root = M.buf_root(0)
  return root ~= nil and root ~= ""
end

local function start_update(root)
  if not root or root == "" then
    return
  end

  local st = ensure_root_state(root)
  local now = uv.now()

  if st.running then
    return
  end
  if (now - (st.last or 0)) < DEBOUNCE_MS then
    return
  end

  st.running = true
  st.last = now

  -- 3 lines:
  -- 1) change id
  -- 2) description
  -- 3) indicators (space-separated, omit empties)
  local template = [[
    change_id.short(8)
    ++ "\n" ++ description.first_line()
    ++ "\n" ++ separate(" ",
      if(conflict, " conflict", ""),
      if(empty, "󰟢 empty", ""),
      if(divergent, "󰘬 divergent", ""),
      if(hidden, "󰘓 hidden", "")
    )
  ]]

  vim.system(
    { "jj", "log", "-r", "@", "-T", template, "--no-graph", "--color", "never" },
    { cwd = root, text = true },
    function(res)
      st.running = false

      if res.code ~= 0 then
        st.change_id, st.desc, st.indicators = "", "", ""
        return
      end

      local lines = vim.split(res.stdout or "", "\n", { plain = true })
      st.change_id = trim(lines[1] or "")
      st.desc = trim(lines[2] or "")
      st.indicators = trim(lines[3] or "")

      pcall(function()
        require("lualine").refresh({ place = { "statusline" } })
      end)
    end
  )
end

---Event handler: ensure root is cached, then update jj info if in repo.
---@param bufnr integer
function M.on_event(bufnr)
  local root = M.buf_root(bufnr)
  if not root or root == "" then
    return
  end
  start_update(root)
end

---Call this once (e.g. during init) to register event-driven updates.
function M.setup()
  local grp = vim.api.nvim_create_augroup("ErgotuJjLualine", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
    group = grp,
    callback = function(args)
      M.on_event(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("DirChanged", {
    group = grp,
    callback = function()
      -- directory changes can invalidate root detection for current buffer
      vim.b.jj_root = nil
      M.on_event(0)
    end,
  })
end

-- Components (do NOT trigger periodic updates; only one-shot fallback if empty)
local function state_for_current()
  local root = M.buf_root(0)
  if not root or root == "" then
    return nil
  end
  local st = ensure_root_state(root)

  -- one-shot fallback: if we have nothing yet (e.g. lualine loads before BufEnter fires)
  if st.change_id == "" and not st.running then
    start_update(root)
  end

  return st
end

function M.change_id()
  local st = state_for_current()
  if not st or st.change_id == "" then
    return ""
  end
  return "󰘬 " .. st.change_id
end

function M.description()
  local st = state_for_current()
  if not st or st.desc == "" then
    return ""
  end
  return shorten(st.desc, 47)
end

function M.indicators()
  local st = state_for_current()
  if not st or st.indicators == "" then
    return ""
  end
  return st.indicators
end

return M
