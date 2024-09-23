-- The existence of the /etc/NIXOS file officializes that it is a NixOS partition
vim.g.nix = vim.uv.fs_stat("/etc/NIXOS") and true or false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("ergotu.config").init()

require("ergotu.config.opts")
require("ergotu.config.autocmds")
require("lazy").setup({
  spec = {
    { import = "ergotu.plugins.colorscheme" },
    { import = "ergotu.plugins.completion" },
    { import = "ergotu.plugins.debugging" },
    { import = "ergotu.plugins.formatting" },
    { import = "ergotu.plugins.git" },
    { import = "ergotu.plugins.lsp" },
    { import = "ergotu.plugins.linting" },
    { import = "ergotu.plugins.snippets" },
    { import = "ergotu.plugins.test" },
    { import = "ergotu.plugins.treesitter" },
    { import = "ergotu.plugins.ui" },
    { import = "ergotu.plugins.utils" },
    { import = "ergotu.plugins.ai" },
    { import = "ergotu.lang" },
  },
  defaults = {
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  ui = {
    border = vim.g.floating_window_options.border,
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
