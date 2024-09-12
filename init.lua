local set = function(nonNix, nix)
  if vim.g.nix == true then
    return nix
  else
    return nonNix
  end
end

-- Bootstrap lazy.nvim
local load_lazy = set(function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
end, function()
  -- Prepend the runtime path with the directory of lazy
  -- This means we can call `require("lazy")`
  vim.opt.rtp:prepend([[lazy.nvim-plugin-path]])
end)

-- Actually execute the loading function we set above
load_lazy()

require("config.opts")
require("config.autocmds")

require("config").init()
require("lazy").setup({
  spec = {
    { import = "plugins.colorscheme" },
    { import = "plugins.completion" },
    { import = "plugins.debugging" },
    { import = "plugins.formatting" },
    { import = "plugins.git" },
    { import = "plugins.lsp" },
    { import = "plugins.linting" },
    { import = "plugins.snippets" },
    { import = "plugins.test" },
    { import = "plugins.treesitter" },
    { import = "plugins.ui" },
    { import = "plugins.utils" },
    { import = "lang" },
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

require("config.keymaps")
require("config.colorscheme")
