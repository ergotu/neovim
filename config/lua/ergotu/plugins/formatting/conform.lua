---@param buf? number
local function enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat

  -- If the buffer has a local value, use that
  if baf ~= nil then
    return baf
  end

  -- Otherwise use the global value if set, or true by default
  return gaf == nil or gaf
end

---@param buf? boolean
local function snacks_toggle(buf)
  return Snacks.toggle({
    name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
    get = function()
      if not buf then
        return vim.g.autoformat == nil or vim.g.autoformat
      end
      return enabled()
    end,
    set = function(enable)
      if enable == nil then
        enable = true
      end
      if buf then
        vim.b.autoformat = enable
      else
        vim.g.autoformat = enable
        vim.b.autoformat = nil
      end
    end,
  })
end

---@type lz.n.Spec[]
return {
  {
    "conform.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format()
        end,
        mode = "",
        desc = "Format buffer",
      },
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    after = function()
      -- Get registered formatter configuration
      -- (language configs are already loaded in ergotu.init)
      local config = require("ergotu.config.formatting").config

      -- Setup toggles
      snacks_toggle():map("<leader>uf")
      snacks_toggle(true):map("<leader>uF")

      -- Setup conform.nvim
      require("conform").setup({
        default_format_opts = config.default_format_opts,
        formatters_by_ft = config.formatters_by_ft,
        format_on_save = function(bufnr)
          if not enabled(bufnr) then
            return
          end
          return config.format_on_save
        end,
        formatters = config.formatters,
      })

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
