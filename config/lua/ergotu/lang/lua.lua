local formatting = require("ergotu.config.formatting")
local linting = require("ergotu.config.linting")
local lsp = require("ergotu.config.lsp")

--- Find a plugin's absolute path by name from the expanded runtime paths.
--- This is needed because in Nix environments, vim.opt.rtp:get() contains
--- glob patterns that lazydev.nvim cannot resolve.
--- @param plugin_name string The plugin directory name (e.g., "snacks.nvim")
--- @return string|nil The absolute path to the plugin, or nil if not found
local function find_plugin_path(plugin_name)
  for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
    if vim.fs.basename(path) == plugin_name then
      return path
    end
  end
  return nil
end

-- LSP Configuration
lsp.add_server("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        -- library = {
        --   vim.env.VIMRUNTIME,
        -- },
      },
    })
  end,
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      completion = { callSnippet = "Replace" },
      doc = { privateName = { "^_" } },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
    },
  },
})

-- Formatting Configuration
formatting.add_formatter("lua", { "stylua" })

-- Linting Configuration
linting.add_linter("lua", { "selene", "luacheck" })
linting.add_linter_config("selene", {
  condition = function(_)
    local root = Ergovim.root.get()
    if root ~= vim.uv.cwd() then
      return false
    end
    return vim.fs.find({ "selene.toml" }, { path = root, upward = true })[1]
  end,
})

linting.add_linter_config("luacheck", {
  condition = function(_)
    local root = Ergovim.root.get()
    if root ~= vim.uv.cwd() then
      return false
    end
    return vim.fs.find({ ".luacheckrc" }, { path = root, upward = true })[1]
  end,
})

-- Test adapter for Lua (neotest-plenary for plugin tests)
local testing = require("ergotu.config.testing")
testing.add_adapter("neotest-plenary", "neotest-plenary")

-- Debug adapter for Lua - Optional, requires local-lua-debugger-vscode setup
-- Uncomment when ready to configure
-- local debugging = require("ergotu.config.debugging")
-- debugging.add_adapter("local-lua", {
--   type = "executable",
--   command = "local-lua-debugger-vscode",
-- })

return {
  {
    "lazydev.nvim",
    ft = "lua",
    after = function()
      require("lazydev").setup({
        enabled = function(root_dir)
          return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
        end,
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          -- Dynamically resolve plugin paths for Nix compatibility
          -- In Nix environments, vim.opt.rtp contains glob patterns that lazydev
          -- cannot resolve, so we must find the actual expanded paths
          {
            path = find_plugin_path("snacks.nvim") or "snacks.nvim",
            words = { "Snacks" },
          },
          {
            path = find_plugin_path("bufferline.nvim") or "bufferline.nvim",
            words = { "bufferline" },
          },
          {
            path = find_plugin_path("mini.hipatterns") or "mini.hipatterns",
            words = { "MiniHipatterns" },
          },
          {
            path = find_plugin_path("lz.n") or "lz.n",
            words = { "LZN", "lz.n" },
          },
        },
      })
    end,
  },
}
