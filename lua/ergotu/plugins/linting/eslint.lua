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
        },
      },
    },
  },
}
