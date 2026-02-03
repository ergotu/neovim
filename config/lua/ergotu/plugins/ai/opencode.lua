return {
  {
    "opencode.nvim",
    before = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        prompts = {
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
          explain = {
            prompt = "Explain @this in detail, including how it works and why",
            submit = true,
          },
          review = {
            prompt = "Review @this for code quality, bugs, and best practices",
            submit = true,
          },
          fix = {
            prompt = "Fix diagnostics and issues in @this",
            submit = true,
          },
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
          testspec = {
            prompt = "Write comprehensive test specifications for @this (describe what tests needed)",
            submit = true,
          },
          testimpl = {
            prompt = "Implement tests for @this using the testing patterns in @buffer",
            submit = true,
          },
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

        contexts = {
          ["@function"] = function(context)
            local node = vim.treesitter.get_node()
            if not node then
              return nil
            end

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
            local node = vim.treesitter.get_node()
            if not node then
              return nil
            end

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
            local node = vim.treesitter.get_node()
            if not node then
              return nil
            end

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

          ["@todos"] = function(context)
            local lines = vim.api.nvim_buf_get_lines(context.buf, 0, -1, false)
            local todos = {}
            for i, line in ipairs(lines) do
              if line:match("TODO") or line:match("FIXME") or line:match("HACK") or line:match("XXX") then
                table.insert(todos, string.format("L%d: %s", i, line:gsub("^%s+", "")))
              end
            end
            if #todos == 0 then
              return nil
            end
            return "TODO items in buffer:\n" .. table.concat(todos, "\n")
          end,

          ["@hover"] = function(context)
            local params = vim.lsp.util.make_position_params(context.win, "utf-16")
            local result = vim.lsp.buf_request_sync(context.buf, "textDocument/hover", params, 1000)
            if not result or vim.tbl_isempty(result) then
              return nil
            end

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
            if not result or vim.tbl_isempty(result) then
              return nil
            end

            local symbols = {}
            for _, res in pairs(result) do
              if res.result then
                for _, symbol in ipairs(res.result) do
                  local kind_name = vim.lsp.protocol.SymbolKind[symbol.kind] or tostring(symbol.kind)
                  table.insert(symbols, string.format("%s: %s", kind_name, symbol.name))
                end
              end
            end
            if #symbols == 0 then
              return nil
            end
            return "Document symbols:\n" .. table.concat(symbols, "\n")
          end,
        },

        ask = {
          prompt = "Ask opencode: ",
          snacks = {
            icon = "💬 ",
          },
        },

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

        events = {
          enabled = true,
          reload = true,
          permissions = {
            enabled = true,
            idle_delay_ms = 500,
          },
        },

        provider = {
          cmd = "opencode --port",
          snacks = {
            auto_insert = true,
          },
        },
      }

      vim.opt.autoread = true

      local opencode
      local function get_opencode()
        if not opencode then
          opencode = require("opencode")
        end
        return opencode
      end

      vim.keymap.set({ "n", "x" }, "<leader>aa", function()
        get_opencode().ask("", { submit = true })
      end, { desc = "Ask opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>as", function()
        get_opencode().select()
      end, { desc = "Select opencode action" })

      vim.keymap.set({ "n", "t" }, "<leader>at", function()
        get_opencode().toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set("n", "<leader>az", function()
        get_opencode().command("session.compact")
      end, { desc = "Compact opencode session" })

      vim.keymap.set({ "n", "x" }, "<leader>ad", function()
        get_opencode().prompt("debug")
      end, { desc = "Debug with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ax", function()
        get_opencode().prompt("explain")
      end, { desc = "Explain with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ar", function()
        get_opencode().prompt("review")
      end, { desc = "Review with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>af", function()
        get_opencode().prompt("fix")
      end, { desc = "Fix diagnostics with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>aT", function()
        get_opencode().prompt("testimpl")
      end, { desc = "Implement tests with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ac", function()
        get_opencode().prompt("refactor")
      end, { desc = "Refactor with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ap", function()
        get_opencode().prompt("profile")
      end, { desc = "Profile performance with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>aS", function()
        get_opencode().prompt("security")
      end, { desc = "Security audit with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>am", function()
        get_opencode().prompt("modernize")
      end, { desc = "Modernize code with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>av", function()
        get_opencode().prompt("validate")
      end, { desc = "Validate code with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ai", function()
        get_opencode().prompt("implement")
      end, { desc = "Implement with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>al", function()
        get_opencode().prompt("simplify")
      end, { desc = "Simplify code with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>adc", function()
        get_opencode().prompt("docstring")
      end, { desc = "Add docstrings with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>adg", function()
        get_opencode().prompt("guide")
      end, { desc = "Create usage guide with opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>ada", function()
        get_opencode().prompt("architecture")
      end, { desc = "Document architecture with opencode" })

      vim.keymap.set("n", "<leader>an", function()
        get_opencode().command("session.new")
      end, { desc = "New opencode session" })

      vim.keymap.set("n", "<leader>aL", function()
        get_opencode().command("session.list")
      end, { desc = "List opencode sessions" })

      vim.keymap.set("n", "<leader>aj", function()
        get_opencode().command("session.undo")
      end, { desc = "Undo opencode session action" })

      vim.keymap.set("n", "<leader>ak", function()
        get_opencode().command("session.redo")
      end, { desc = "Redo opencode session action" })

      vim.keymap.set({ "n", "x" }, "go", function()
        return get_opencode().operator("@this ")
      end, { desc = "Add range to opencode", expr = true })

      vim.keymap.set("n", "goo", function()
        return get_opencode().operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set({ "n", "x" }, "<leader>ab", function()
        get_opencode().ask("@buffer: ", { submit = true })
      end, { desc = "Ask about buffer with opencode" })

      vim.keymap.set("n", "<leader>ag", function()
        get_opencode().ask("@diagnostics: ", { submit = true })
      end, { desc = "Ask about diagnostics with opencode" })

      vim.keymap.set("n", "<leader>ao", function()
        get_opencode().ask("@todos: ", { submit = true })
      end, { desc = "Ask about TODOs with opencode" })

      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:session.idle",
        callback = function()
          vim.notify("Opencode session ready", vim.log.levels.INFO)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:error",
        callback = function(args)
          local event = args.data.event
          vim.notify("Opencode error: " .. vim.inspect(event), vim.log.levels.ERROR)
        end,
      })

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
