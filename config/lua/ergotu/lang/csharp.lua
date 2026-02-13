local formatting = require("ergotu.config.formatting")
local lsp = require("ergotu.config.lsp")

-- C# Formatter
formatting.add_formatter("cs", { "csharpier" })
formatting.add_formatter_config("csharpier", {
  command = "dotnet-csharpier",
  args = { "--write-stdout" },
})

-- Register roslyn in the LSP config registry
-- This marks it as a known server so lspconfig won't try to auto-setup
lsp.add_server("roslyn", {
  enabled = true, -- Mark as enabled but will be handled by custom setup
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
      dotnet_enable_tests_code_lens = true,
    },
    ["csharp|completion"] = {
      dotnet_provide_regex_completions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "openFiles",
      dotnet_compiler_diagnostics_scope = "openFiles",
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
  },
})

-- Roslyn LSP plugin for C#
---@type lz.n.Spec[]
return {
  {
    "roslyn.nvim",
    ft = { "cs", "razor", "cshtml" },
    before = function()
      -- Ensure lspconfig is loaded first
      LZN.trigger_load("nvim-lspconfig")
    end,
    after = function()
      ---@module 'roslyn'
      ---@type RoslynNvimConfig
      local opts = {
        -- Roslyn handles file watching internally
        filewatching = "roslyn",

        -- Search parent directories for solution files
        broad_search = true,

        -- Don't lock to first solution found (allow switching)
        lock_target = false,

        -- Show notifications during initialization
        silent = false,
      }

      -- Setup the roslyn plugin
      require("roslyn").setup(opts)

      vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        pattern = "*",
        callback = function()
          local clients = vim.lsp.get_clients({ name = "roslyn" })
          if not clients or #clients == 0 then
            return
          end

          local client = clients[1]
          local buffers = vim.lsp.get_buffers_by_client_id(client.id)
          for _, buf in ipairs(buffers) do
            local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
            client:request("textDocument/diagnostic", params, nil, buf)
          end
        end,
      })

      local handles = {}

      vim.api.nvim_create_autocmd("User", {
        pattern = "RoslynRestoreProgress",
        callback = function(ev)
          local token = ev.data.params[1]
          local handle = handles[token]
          if handle then
            handle:report({
              title = ev.data.params[2].state,
              message = ev.data.params[2].message,
            })
          else
            handles[token] = require("fidget.progress").handle.create({
              title = ev.data.params[2].state,
              message = ev.data.params[2].message,
              lsp_client = {
                name = "roslyn",
              },
            })
          end
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "RoslynRestoreResult",
        callback = function(ev)
          local handle = handles[ev.data.token]
          handles[ev.data.token] = nil

          if handle then
            handle.message = ev.data.err and ev.data.err.message or "Restore completed"
            handle:finish()
          end
        end,
      })

      vim.api.nvim_create_user_command("CSFixUsings", function()
        local bufnr = vim.api.nvim_get_current_buf()

        local clients = vim.lsp.get_clients({ name = "roslyn" })
        if not clients or vim.tbl_isempty(clients) then
          vim.notify("Couldn't find client", vim.log.levels.ERROR, { title = "Roslyn" })
          return
        end

        local client = clients[1]
        local action = {
          kind = "quickfix",
          data = {
            CustomTags = { "RemoveUnnecessaryImports" },
            TextDocument = { uri = vim.uri_from_bufnr(bufnr) },
            CodeActionPath = { "Remove unnecessary usings" },
            Range = {
              ["start"] = { line = 0, character = 0 },
              ["end"] = { line = 0, character = 0 },
            },
            UniqueIdentifier = "Remove unnecessary usings",
          },
        }

        client:request("codeAction/resolve", action, function(err, resolved_action)
          if err then
            vim.notify("Fix using directives failed", vim.log.levels.ERROR, { title = "Roslyn" })
            return
          end
          vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding)
        end)
      end, { desc = "Remove unnecessary using directives" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          if client and (client.name == "roslyn" or client.name == "roslyn_ls") then
            vim.api.nvim_create_autocmd("InsertCharPre", {
              desc = "Roslyn: Trigger an auto insert on '/'.",
              buffer = bufnr,
              callback = function()
                local char = vim.v.char

                if char ~= "/" then
                  return
                end

                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                row, col = row - 1, col + 1
                local uri = vim.uri_from_bufnr(bufnr)

                local params = {
                  _vs_textDocument = { uri = uri },
                  _vs_position = { line = row, character = col },
                  _vs_ch = char,
                  _vs_options = {
                    tabSize = vim.bo[bufnr].tabstop,
                    insertSpaces = vim.bo[bufnr].expandtab,
                  },
                }

                -- NOTE: We should send textDocument/_vs_onAutoInsert request only after
                -- buffer has changed.
                vim.defer_fn(function()
                  client:request(
                    ---@diagnostic disable-next-line: param-type-mismatch
                    "textDocument/_vs_onAutoInsert",
                    params,
                    function(err, result, _)
                      if err or not result then
                        return
                      end

                      vim.snippet.expand(result._vs_textEdit.newText)
                    end,
                    bufnr
                  )
                end, 1)
              end,
            })
          end
        end,
      })
    end,
  },
}
