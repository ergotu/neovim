---@class ergotu.util.lualine
---@field jj ergotu.util.lualine.jj
local M = {}

---@alias PrettyPathOpts {max_dirs?: number, separator?: string, newfile_status?: string, modified_status?: string, readonly_status?: string}

---@param opts? PrettyPathOpts
---@return function Lualine component function
function M.pretty_path(opts)
  opts = vim.tbl_deep_extend("force", {
    max_dirs = 4,
    separator = "/",
    newfile_status = "[+]",
    modified_status = " ●",
    readonly_status = " ",
  }, opts or {})

  return function()
    local bufname = vim.api.nvim_buf_get_name(0)

    -- Handle empty/unnamed buffers
    if bufname == "" then
      return opts.newfile_status
    end

    -- Handle special buffers (help, terminal, etc.)
    local buftype = vim.bo.buftype
    if buftype ~= "" then
      return vim.fn.fnamemodify(bufname, ":t")
    end

    -- Get project root
    local root = Ergovim.root.get()

    -- Calculate relative path from root
    local relative_path = vim.fn.fnamemodify(bufname, ":~:.")

    -- If file is not under root, try to make it relative to root
    if root and root ~= "" then
      local bufname_full = vim.fn.fnamemodify(bufname, ":p")
      local root_full = vim.fn.fnamemodify(root, ":p")

      -- Check if file is under root
      if bufname_full:sub(1, #root_full) == root_full then
        relative_path = bufname_full:sub(#root_full + 1)
        -- Remove leading slash
        if relative_path:sub(1, 1) == "/" then
          relative_path = relative_path:sub(2)
        end
      end
    end

    -- Split path into components
    local parts = vim.split(relative_path, "/", { plain = true })

    -- Shorten path if too deep
    local path_str
    if #parts > opts.max_dirs then
      -- Keep first directory, ellipsis, parent dir, and filename
      local shortened_parts = {}
      table.insert(shortened_parts, parts[1]) -- First directory
      table.insert(shortened_parts, "…") -- Ellipsis
      table.insert(shortened_parts, parts[#parts - 1]) -- Parent directory
      table.insert(shortened_parts, parts[#parts]) -- Filename
      path_str = table.concat(shortened_parts, opts.separator)
    else
      path_str = table.concat(parts, opts.separator)
    end

    -- Add status indicators
    local status = ""
    if vim.bo.readonly then
      status = status .. opts.readonly_status
    end
    if vim.bo.modified then
      status = status .. opts.modified_status
    end

    return path_str .. status
  end
end

return M
