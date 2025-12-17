---@type lz.n.Spec[]
return {
  {
    "nvim-dap-ui",
    dependencies = { "nvim-nio" },
    event = "DeferredUIEnter",
    after = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local config = require("ergotu.config.debugging").config

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      })

      -- Auto open/close UI
      if config.ui.auto_open then
        dap.listeners.before.attach.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          dapui.close()
        end
      end
    end,
  },
}
