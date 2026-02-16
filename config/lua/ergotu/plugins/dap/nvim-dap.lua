---@type lz.n.Spec[]
return {
  {
    "nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>dR",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "Clear Breakpoints",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle UI",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "Eval",
      },
      {
        "<leader>dE",
        function()
          require("dapui").eval(vim.fn.input("[Expression] > "))
        end,
        mode = { "n", "v" },
        desc = "Eval Expression",
      },
    },
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapStepOver",
      "DapStepInto",
      "DapStepOut",
      "DapTerminate",
    },
    after = function()
      local dap = require("dap")
      local langs = require("ergotu.util.langs")
      local config = langs.debugging.config
      local icons = require("ergotu.config.icons")

      -- Populate icons
      config.ui.icons = icons.dap
      config.signs = {
        DapBreakpoint = { text = icons.dap.Breakpoint, texthl = "DapBreakpoint" },
        DapBreakpointCondition = { text = icons.dap.BreakpointCondition, texthl = "DapBreakpoint" },
        DapBreakpointRejected = { text = icons.dap.BreakpointRejected[1], texthl = icons.dap.BreakpointRejected[2] },
        DapLogPoint = { text = icons.dap.LogPoint, texthl = "DapLogPoint" },
        DapStopped = { text = icons.dap.Stopped[1], texthl = icons.dap.Stopped[2], linehl = icons.dap.Stopped[3] },
      }

      -- Set signs
      for name, sign in pairs(config.signs) do
        vim.fn.sign_define(name, sign)
      end

      -- Register adapters from config
      for name, adapter in pairs(config.adapters) do
        dap.adapters[name] = adapter
      end

      -- Register configurations from config
      for filetype, configs in pairs(config.configurations) do
        dap.configurations[filetype] = configs
      end

      -- VS Code launch.json support
      -- Load .vscode/launch.json from the current working directory
      require("dap.ext.vscode").load_launchjs(nil, nil)

      -- Overseer DAP integration
      if pcall(require, "overseer") then
        require("overseer").enable_dap()
      end
    end,
    wk = {
      { "<leader>d", group = "debug" },
    },
  },
}
