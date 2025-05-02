local autoformat = vim.g.eslint_autoformat == nil or vim.g.eslint_autoformat

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = "auto" },
            format = autoformat,
          },
          before_init = function(params, config)
            -- Set the workspace folder setting for correct search of tsconfig.json files etc.
            config.settings.workspaceFolder = {
              uri = params.rootPath,
              name = vim.fn.fnamemodify(params.rootPath, ":t"),
            }
          end,
          handlers = {
            ["eslint/openDoc"] = function(_, params)
              vim.ui.open(params.url)
              return {}
            end,
            ["eslint/probeFailed"] = function()
              vim.notify("LSP[eslint]: Probe failed.", vim.log.levels.WARN)
              return {}
            end,
            ["eslint/noLibrary"] = function()
              vim.notify("LSP[eslint]: Unable to load ESLint library.", vim.log.levels.WARN)
              return {}
            end,
          },
        },
      },
    },
  },
}
