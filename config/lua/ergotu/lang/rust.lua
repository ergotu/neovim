local debugging = require("ergotu.config.debugging")
local formatting = require("ergotu.config.formatting")
local lsp = require("ergotu.config.lsp")
local testing = require("ergotu.config.testing")

-- LSP
lsp.add_server("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = { enable = true },
      },
      checkOnSave = true,
      procMacro = { enable = true },
    },
  },
})

-- Formatting
formatting.add_formatter("rust", { "rustfmt" })

-- Debug adapter (CodeLLDB)
debugging.add_adapter("codelldb", {
  type = "server",
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  },
})

debugging.add_configuration("rust", {
  {
    type = "codelldb",
    request = "launch",
    name = "Launch file",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
  {
    type = "codelldb",
    request = "launch",
    name = "Debug test",
    program = function()
      return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
})

-- Test adapter
testing.add_adapter("neotest-rust", "neotest-rust")
