---@param filter vim.lsp.get_clients.Filter
---@param keys table[]
local function set_keymap(filter, keys)
  for _, key in ipairs(keys) do
    local modes = key.mode or "n"
    local lhs, rhs = key[1], key[2]

    local base_opts = {
      desc = key.desc,
      nowait = key.nowait,
      silent = key.silent ~= false,
      expr = key.expr,
      enabled = key.enabled,
    }

    if key.has then
      local methods = type(key.has) == "string" and { key.has } or key.has
      for _, method in ipairs(methods) do
        method = method:find("/") and method or ("textDocument/" .. method)
        local opts = vim.tbl_extend("force", base_opts, {
          lsp = vim.tbl_extend("force", vim.deepcopy(filter), { method = method }),
        })
        Snacks.keymap.set(modes, lhs, rhs, opts)
      end
    else
      local opts = vim.tbl_extend("force", base_opts, { lsp = filter })
      Snacks.keymap.set(modes, lhs, rhs, opts)
    end
  end
end

---@type lz.n.Spec[]
return {
  {
    "nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    before = function()
      LZN.trigger_load("inc-rename.nvim")
    end,
    after = vim.schedule_wrap(function()
      local config = require("ergotu.config.lsp").config
      local icons = require("ergotu.config.icons")

      config = vim.tbl_deep_extend("force", {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {},
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = { "vue" },
        },
        codelens = {
          enabled = true,
        },
        folds = {
          enabled = true,
        },
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
      }, config)

      -- Set diagnostic signs
      config.diagnostics.signs.text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      }

      -- Configure base server settings
      config.servers["*"] = vim.tbl_deep_extend("force", {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
				-- stylua: ignore
				keys = {
					{ "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
					{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
					{ "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
					{ "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
					{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
					{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
					{ "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
					{ "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
					{ "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
					{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
					{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
					{ "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
					{ "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode = {"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
					-- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
          {
            "<leader>cr",
            function()
              local inc_rename = require("inc_rename")
              return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
            end,
            expr = true,
            desc = "Rename (inc-rename.nvim)",
            has = "rename",
          },
					{ "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight", desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
					{ "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight", desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
					{ "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight", desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
					{ "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight", desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
					{ "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols", has = "documentSymbol" },
					{ "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
				},
      }, config.servers["*"] or {})

      -- Language configs are already loaded in ergotu.init

      -- Setup keymaps for each server
      for server, server_opts in pairs(config.servers) do
        if type(server_opts) == "table" and server_opts.keys then
          set_keymap({ name = server ~= "*" and server or nil }, server_opts.keys)
        end
      end

      -- Inlay hints
      if config.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
          Snacks.toggle.inlay_hints():map("<leader>uh")
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(config.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- Folds
      if config.folds.enabled then
        Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function(_buffer)
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
          vim.wo.foldlevel = 99
        end)
      end

      -- Code lens
      if config.codelens.enabled and vim.lsp.codelens then
        Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- Diagnostics
      if type(config.diagnostics.virtual_text) == "table" and config.diagnostics.virtual_text.prefix == "icons" then
        config.diagnostics.virtual_text.prefix = function(diagnostic)
          local diagIcons = icons.diagnostics
          for d, icon in pairs(diagIcons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return "●"
        end
      end

      vim.diagnostic.config(vim.deepcopy(config.diagnostics))

      -- Configure and enable LSP servers
      if config.servers["*"] then
        vim.lsp.config("*", config.servers["*"])
      end

      for server, server_opts in pairs(config.servers) do
        if server ~= "*" then
          server_opts = server_opts == true and {} or (not server_opts) and { enabled = false } or server_opts

          if server_opts.enabled ~= false then
            local setup = config.setup[server] or config.setup["*"]

            -- If custom setup returns true, it has handled everything
            local handled_by_custom = setup and setup(server, server_opts)
            if not handled_by_custom then
              vim.lsp.config(server, server_opts)
              vim.lsp.enable(server)
            end
          end
        end
      end
    end),
  },
}
