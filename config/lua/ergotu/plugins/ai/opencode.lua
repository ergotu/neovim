return {
  {
    "opencode.nvim",
    before = function()
      -- ============================================================================
      -- OPENCODE.NVIM ENHANCED CONFIGURATION
      -- Comprehensive productivity setup with custom prompts, contexts, and keymaps
      -- ============================================================================

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- ========================================================================
        -- CUSTOM PROMPTS (16 total)
        -- ========================================================================
        prompts = {
          -- Debugging & Analysis (4 prompts)
          debug = {
            prompt = "Debug @this and explain what's happening, including potential issues",
            submit = true,
          },
          trace = {
            prompt = "Trace through @this step-by-step with example inputs/outputs and explain the flow",
            submit = true,
          },
          profile = {
            prompt = "Analyze @this for performance bottlenecks and suggest optimizations",
            submit = true,
          },
          validate = {
            prompt = "Validate @this against edge cases and assumptions - identify potential bugs",
            submit = true,
          },

          -- Code Quality (5 prompts)
          types = {
            prompt = "Add type annotations and type safety improvements to @this",
            submit = true,
          },
          refactor = {
            prompt = "Refactor @this: ",
            ask = true,
            submit = false,
          },
          simplify = {
            prompt = "Simplify @this while maintaining functionality and readability",
            submit = true,
          },
          security = {
            prompt = "Security audit of @this - identify vulnerabilities and protection strategies",
            submit = true,
          },
          modernize = {
            prompt = "Modernize @this to use current language/framework features and patterns",
            submit = true,
          },

          -- Testing (2 prompts)
          testspec = {
            prompt = "Write comprehensive test specifications for @this (describe what tests needed)",
            submit = true,
          },
          testimpl = {
            prompt = "Implement tests for @this using the testing patterns in @buffer",
            submit = true,
          },

          -- Documentation (3 prompts)
          docstring = {
            prompt = "Add comprehensive docstrings/comments documenting @this",
            submit = true,
          },
          guide = {
            prompt = "Create a usage guide for @this with practical examples",
            submit = true,
          },
          architecture = {
            prompt = "Document the architecture and design decisions for @this",
            submit = true,
          },

          -- Integration (2 prompts)
          implement = {
            prompt = "Implement: ",
            ask = true,
            submit = false,
          },
          adapt = {
            prompt = "Adapt @this for: ",
            ask = true,
            submit = false,
          },
        },

        -- ========================================================================
        -- CUSTOM CONTEXTS (6 total)
        -- ========================================================================
        contexts = {
          -- Treesitter-based contexts
          ["@function"] = function(context)
            local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
            if not ok then return nil end

            local node = ts_utils.get_node_at_cursor()
            if not node then return nil end

            -- Find parent function node
            while node do
              local node_type = node:type()
              if node_type:match("function") or node_type:match("method") then
                local start_row, _, end_row, _ = node:range()
                return context.format({
                  buf = context.buf,
                  start_line = start_row + 1,
                  end_line = end_row + 1,
                })
              end
              node = node:parent()
            end
            return nil
          end,

          ["@class"] = function(context)
            local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
            if not ok then return nil end

            local node = ts_utils.get_node_at_cursor()
            if not node then return nil end

            -- Find parent class/module node
            while node do
              local node_type = node:type()
              if node_type:match("class") or node_type:match("module") or node_type:match("struct") then
                local start_row, _, end_row, _ = node:range()
                return context.format({
                  buf = context.buf,
                  start_line = start_row + 1,
                  end_line = end_row + 1,
                })
              end
              node = node:parent()
            end
            return nil
          end,

          ["@block"] = function(context)
            local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
            if not ok then return nil end

            local node = ts_utils.get_node_at_cursor()
            if not node then return nil end

            -- Find current block node
            while node do
              local node_type = node:type()
              if node_type:match("block") or node_type:match("body") then
                local start_row, _, end_row, _ = node:range()
                return context.format({
                  buf = context.buf,
                  start_line = start_row + 1,
                  end_line = end_row + 1,
                })
              end
              node = node:parent()
            end
            return nil
          end,

          -- Project-aware contexts
          ["@todos"] = function(context)
            local lines = vim.api.nvim_buf_get_lines(context.buf, 0, -1, false)
            local todos = {}
            for i, line in ipairs(lines) do
              if line:match("TODO") or line:match("FIXME") or line:match("HACK") or line:match("XXX") then
                table.insert(todos, string.format("L%d: %s", i, line:gsub("^%s+", "")))
              end
            end
            if #todos == 0 then return nil end
            return "TODO items in buffer:\n" .. table.concat(todos, "\n")
          end,

          -- LSP-based contexts
          ["@hover"] = function(context)
            local params = vim.lsp.util.make_position_params(context.win)
            local result = vim.lsp.buf_request_sync(context.buf, "textDocument/hover", params, 1000)
            if not result or vim.tbl_isempty(result) then return nil end

            for _, res in pairs(result) do
              if res.result and res.result.contents then
                local contents = res.result.contents
                if type(contents) == "string" then
                  return contents
                elseif contents.value then
                  return contents.value
                end
              end
            end
            return nil
          end,

          ["@symbols"] = function(context)
            local params = { textDocument = vim.lsp.util.make_text_document_params(context.buf) }
            local result = vim.lsp.buf_request_sync(context.buf, "textDocument/documentSymbol", params, 1000)
            if not result or vim.tbl_isempty(result) then return nil end

            local symbols = {}
            for _, res in pairs(result) do
              if res.result then
                for _, symbol in ipairs(res.result) do
                  local kind_name = vim.lsp.protocol.SymbolKind[symbol.kind] or tostring(symbol.kind)
                  table.insert(symbols, string.format("%s: %s", kind_name, symbol.name))
                end
              end
            end
            if #symbols == 0 then return nil end
            return "Document symbols:\n" .. table.concat(symbols, "\n")
          end,
        },

        -- ========================================================================
        -- ASK CONFIGURATION
        -- ========================================================================
        ask = {
          prompt = "Ask opencode: ",
          snacks = {
            icon = "💬 ",
          },
        },

        -- ========================================================================
        -- SELECT CONFIGURATION
        -- ========================================================================
        select = {
          prompt = "opencode: ",
          sections = {
            prompts = true,
            commands = {
              ["session.new"] = "New Session",
              ["session.list"] = "List Sessions",
              ["session.compact"] = "Compact Session",
              ["session.undo"] = "Undo",
              ["session.redo"] = "Redo",
            },
            provider = true,
          },
        },

        -- ========================================================================
        -- EVENTS CONFIGURATION
        -- ========================================================================
        events = {
          enabled = true,
          reload = true, -- Auto-reload edited buffers
          permissions = {
            enabled = true,
            idle_delay_ms = 500,
          },
        },

        -- ========================================================================
        -- PROVIDER CONFIGURATION
        -- ========================================================================
        provider = {
          cmd = "opencode --port",
          snacks = {
            auto_insert = true,
            -- win = {
            --   position = 'right'  -- Already default, keeping right side
            -- }
          },
        },
      }

      -- Required for auto-reload functionality
      vim.opt.autoread = true

      -- ========================================================================
      -- KEYMAPS (26 total)
      -- ========================================================================

      local opencode = function()
        return require("opencode")
      end

      -- ------------------------------------------------------------------------
      -- Core Operations (4 maps)
      -- ------------------------------------------------------------------------
      vim.keymap.set({ "n", "x" }, "<leader>aa", function()
        opencode().ask("@this: ", { submit = true })
      end, { desc = "Ask opencode with @this" })

      vim.keymap.set({ "n", "x" }, "<leader>as", function()
        opencode().select()
      end, { desc = "Select opencode action" })

      vim.keymap.set({ "n", "t" }, "<leader>at", function()
        opencode().toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set("n", "<leader>az", function()
        opencode().command("session.compact")
      end, { desc = "Compact opencode session" })

      -- ------------------------------------------------------------------------
      -- Quick Prompts (12 maps)
      -- ------------------------------------------------------------------------
      vim.keymap.set({ "n", "x" }, "<leader>ad", function()
        opencode().prompt("debug")
      end, { desc = "Debug with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ax", function()
        opencode().prompt("explain")
      end, { desc = "Explain with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ar", function()
        opencode().prompt("review")
      end, { desc = "Review with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>af", function()
        opencode().prompt("fix")
      end, { desc = "Fix diagnostics with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>aT", function()
        opencode().prompt("testimpl")
      end, { desc = "Implement tests with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ac", function()
        opencode().prompt("refactor")
      end, { desc = "Refactor with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ap", function()
        opencode().prompt("profile")
      end, { desc = "Profile performance with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>aS", function()
        opencode().prompt("security")
      end, { desc = "Security audit with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>am", function()
        opencode().prompt("modernize")
      end, { desc = "Modernize code with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>av", function()
        opencode().prompt("validate")
      end, { desc = "Validate code with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ai", function()
        opencode().prompt("implement")
      end, { desc = "Implement with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>al", function()
        opencode().prompt("simplify")
      end, { desc = "Simplify code with opencode" })

      -- ------------------------------------------------------------------------
      -- Documentation (3 maps)
      -- ------------------------------------------------------------------------
      vim.keymap.set({ "n", "x" }, "<leader>adc", function()
        opencode().prompt("docstring")
      end, { desc = "Add docstrings with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>adg", function()
        opencode().prompt("guide")
      end, { desc = "Create usage guide with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ada", function()
        opencode().prompt("architecture")
      end, { desc = "Document architecture with opencode" })

      -- ------------------------------------------------------------------------
      -- Session Management (4 maps)
      -- ------------------------------------------------------------------------
      vim.keymap.set("n", "<leader>an", function()
        opencode().command("session.new")
      end, { desc = "New opencode session" })

      vim.keymap.set("n", "<leader>aL", function()
        opencode().command("session.list")
      end, { desc = "List opencode sessions" })

      vim.keymap.set("n", "<leader>aj", function()
        opencode().command("session.undo")
      end, { desc = "Undo opencode session action" })

      vim.keymap.set("n", "<leader>ak", function()
        opencode().command("session.redo")
      end, { desc = "Redo opencode session action" })

      -- ------------------------------------------------------------------------
      -- Operator Mappings (2 maps)
      -- ------------------------------------------------------------------------
      vim.keymap.set({ "n", "x" }, "go", function()
        return opencode().operator("@this ")
      end, { desc = "Add range to opencode", expr = true })

      vim.keymap.set("n", "goo", function()
        return opencode().operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      -- ------------------------------------------------------------------------
      -- Context-Specific Quick Access (3 maps)
      -- ------------------------------------------------------------------------
      vim.keymap.set({ "n", "x" }, "<leader>ab", function()
        opencode().ask("@buffer: ", { submit = true })
      end, { desc = "Ask about buffer with opencode" })

      vim.keymap.set("n", "<leader>ag", function()
        opencode().ask("@diagnostics: ", { submit = true })
      end, { desc = "Ask about diagnostics with opencode" })

      vim.keymap.set("n", "<leader>ao", function()
        opencode().ask("@todos: ", { submit = true })
      end, { desc = "Ask about TODOs with opencode" })

      -- ========================================================================
      -- EVENT HANDLERS (3 events)
      -- ========================================================================

      -- Session completion notification
      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:session.idle",
        callback = function()
          vim.notify("Opencode session ready", vim.log.levels.INFO)
        end,
      })

      -- Error logging
      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:error",
        callback = function(args)
          local event = args.data.event
          vim.notify("Opencode error: " .. vim.inspect(event), vim.log.levels.ERROR)
        end,
      })

      -- Permission request notification (optional - complements built-in handling)
      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:permission.asked",
        callback = function(args)
          local event = args.data.event
          if event.properties then
            vim.notify("Permission requested: " .. vim.inspect(event.properties), vim.log.levels.WARN)
          end
        end,
      })
    end,
  },
}

-- ============================================================================
-- STATUSLINE INTEGRATION
-- ============================================================================
-- To add opencode status to lualine, add this to your lualine sections:
--
-- {
--   function()
--     return require("opencode").statusline()
--   end,
--   cond = function()
--     return package.loaded["opencode"] ~= nil
--   end,
-- }
--
-- ============================================================================
