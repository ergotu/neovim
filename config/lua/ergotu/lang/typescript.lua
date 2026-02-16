local langs = require("ergotu.util.langs")
local lsp = langs.lsp

lsp.add_server("eslint", {
  settings = {
    -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
    workingDirectories = { mode = "auto" },
    format = vim.g.eslint_autoformat == nil or vim.g.eslint_autoformat,
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
})

-- Disable ts_ls in favor of vtsls
lsp.add_server("ts_ls", {
  enabled = false,
})

-- TypeScript/JavaScript LSP Server (vtsls)
lsp.add_server("vtsls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
  },
  keys = {
    {
      "gD",
      function()
        local params = vim.lsp.util.make_position_params(0)
        vim.lsp.buf_request(0, "workspace/executeCommand", {
          command = "typescript.goToSourceDefinition",
          arguments = { params.textDocument.uri, params.position },
        })
      end,
      desc = "Goto Source Definition",
    },
    {
      "gR",
      function()
        vim.lsp.buf_request(0, "workspace/executeCommand", {
          command = "typescript.findAllFileReferences",
          arguments = { vim.uri_from_bufnr(0) },
        })
      end,
      desc = "File References",
    },
    {
      "<leader>co",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end,
      desc = "Organize Imports",
    },
    {
      "<leader>cM",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            only = { "source.addMissingImports.ts" },
            diagnostics = {},
          },
        })
      end,
      desc = "Add missing imports",
    },
    {
      "<leader>cu",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            only = { "source.removeUnused.ts" },
            diagnostics = {},
          },
        })
      end,
      desc = "Remove unused imports",
    },
    {
      "<leader>cD",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            only = { "source.fixAll.ts" },
            diagnostics = {},
          },
        })
      end,
      desc = "Fix all diagnostics",
    },
    {
      "<leader>cV",
      function()
        vim.lsp.buf_request(0, "workspace/executeCommand", { command = "typescript.selectTypeScriptVersion" })
      end,
      desc = "Select TS workspace version",
    },
  },
})

-- Custom setup handlers
lsp.add_setup("ts_ls", function()
  return true -- skip ts_ls setup, using vtsls instead
end)

lsp.add_setup("vtsls", function(_server, opts)
  -- Register move-to-file refactoring command handler
  Snacks.util.lsp.on({ name = "vtsls" }, function(_, client)
    client.commands["_typescript.moveToFileRefactoring"] = function(command, _ctx)
      ---@diagnostic disable-next-line: assign-type-mismatch
      ---@type string, string, lsp.Range
      local action, uri, range = unpack(command.arguments)

      local function move(newf)
        vim.lsp.buf_request(0, "workspace/executeCommand", {
          command = command.command,
          arguments = { action, uri, range, newf },
        })
      end

      local fname = vim.uri_to_fname(uri)
      -- Use Snacks picker if available, otherwise fall back to vim.ui.input
      local ok_snacks, snacks = pcall(require, "snacks")
      if ok_snacks and snacks.picker then
        snacks.picker.pick({
          label = "Select move destination:",
          cwd = vim.fn.fnamemodify(fname, ":h"),
          onselect = function(item)
            move(item.path)
          end,
        })
      else
        vim.ui.input({
          prompt = "Select move destination:",
          default = fname,
          completion = "file",
        }, function(newf)
          if newf and newf ~= "" then
            move(newf)
          end
        end)
      end
    end
  end)

  -- Copy typescript settings to javascript settings
  opts.settings.javascript = vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})

  return false -- use default lspconfig setup
end)

-- Debug adapter for Node.js/TypeScript
local debugging = langs.debugging
debugging.add_adapter("pwa-node", {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  },
})

debugging.add_configuration("typescript", {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach",
    processId = function()
      return require("dap.utils").pick_process()
    end,
    cwd = "${workspaceFolder}",
  },
})

debugging.add_configuration("javascript", {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
})

-- Test adapters for JS/TS
local testing = langs.testing
testing.add_adapter("neotest-jest", "neotest-jest")
testing.add_adapter("neotest-vitest", "neotest-vitest")
