require("nixCatsUtils").setup({
  non_nix_value = true,
})

-- NOTE: You might want to move the lazy-lock.json file
local function getlockfilepath()
  if require("nixCatsUtils").isNixCats and type(nixCats.settings.unwrappedCfgPath) == "string" then
    return nixCats.settings.unwrappedCfgPath .. "/lazy-lock.json"
  else
    return vim.fn.stdpath("config") .. "/lazy-lock.json"
  end
end

require("ergotu.config.opts")
require("ergotu.config.autocmds")

require("ergotu.config").init()
require("nixCatsUtils.lazyCat").setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), {
  spec = {
    { import = "ergotu.plugins.colorscheme" },
    { import = "ergotu.plugins.snacks" },
    { import = "ergotu.plugins.ui" },
    { import = "ergotu.plugins.treesitter" },
    { import = "ergotu.plugins.lsp" },
    { import = "ergotu.plugins.completion" },
    { import = "ergotu.plugins.snippets" },
    { import = "ergotu.plugins.linting" },
    { import = "ergotu.plugins.formatting" },
    { import = "ergotu.plugins.debugging" },
    { import = "ergotu.plugins.test" },
    { import = "ergotu.plugins.utils" },
    { import = "ergotu.plugins.zettelkasten" },
    { import = "ergotu.plugins.git" },
    { import = "ergotu.plugins.ai" },
    { import = "ergotu.lang" },
  },
  lockfile = getlockfilepath(),
  defaults = {
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = {
    colorscheme = { "catppuccin-mocha" },
  },
  ui = {
    size = {
      width = 0.8,
      height = 0.9,
    },
    border = vim.g.floating_window_options.border,
    title = "Lazy.nvim",
    custom_keys = {
      ["<localleader>d"] = function(plugin)
        dd(plugin)
      end,
    },
  },
  diff = {
    cmd = "diffview.nvim",
  },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      paths = { vim.g.rtp_path },
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

require("ergotu.config.keymaps")
require("ergotu.config.colorscheme")
