return {
  "stevearc/conform.nvim",
  event = "LazyFile",
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>cf",
      function()
        require("conform").format()
      end,
      mode = "",
      desc = "Format buffer",
    },
    {
      -- Customize or remove this keymap to your liking
      "<leader>cF",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer (async)",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      -- Use the "*" filetype to run formatters on all filetypes.
      -- ["*"] = { "codespell" },
      -- Use the "_" filetype to run formatters on filetypes that don't
      -- have other formatters configured.
      ["_"] = { "trim_whitespace" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    format_on_save = function(bufnr)
      if not Util.format.enabled(bufnr) then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    -- Customize formatters
    formatters = {},
  },
}
