---@type lz.n.Spec[]
return {
  {
    "neotest",
    keys = {
      {
        "<leader>ta",
        function()
          require("neotest").run.attach()
        end,
        desc = "Attach",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Test Files",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug Nearest",
      },
    },
    cmd = { "Neotest" },
    after = function()
      local neotest = require("neotest")
      local langs = require("ergotu.util.langs")
      local config = langs.testing.config
      local icons = require("ergotu.config.icons")

      -- Build adapter list
      local adapters = {}
      for _, adapter in pairs(config.adapters) do
        if type(adapter) == "string" then
          table.insert(adapters, require(adapter))
        else
          table.insert(adapters, adapter)
        end
      end

      neotest.setup({
        adapters = adapters,
        icons = icons.test,
        status = config.settings.status,
        output = config.settings.output,
        quickfix = config.settings.quickfix,
        summary = config.settings.summary,
        discovery = { enabled = true },
        diagnostic = { enabled = true },
        -- Trouble integration
        consumers = {
          trouble = function(client)
            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end
              local trouble = require("trouble")
              local _ = assert(client:get_position(nil, { adapter = adapter_id }))

              local failed = 0
              for _, result in pairs(results) do
                if result.status == "failed" then
                  failed = failed + 1
                end
              end

              vim.schedule(function()
                if failed > 0 then
                  trouble.open({ mode = "quickfix", focus = false })
                else
                  trouble.close()
                end
              end)
            end
          end,
          overseer = require("neotest.consumers.overseer"),
        },
      })
    end,
    wk = {
      { "<leader>t", group = "test", icon = "󰙨 " },
    },
  },
}
