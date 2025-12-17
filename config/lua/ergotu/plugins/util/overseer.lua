---@type lz.n.Spec[]
return {
  {
    "overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache",
    },
    keys = {
      { "<leader>ow", "<cmd>OverseerToggle<cr>", desc = "Task list" },
      { "<leader>oo", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
      { "<leader>oi", "<cmd>checkhealth overseer<cr>", desc = "Overseer Info" },
      { "<leader>ob", "<cmd>OverseerBuild<cr>", desc = "Task builder" },
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
      { "<leader>oc", "<cmd>OverseerClearCache<cr>", desc = "Clear cache" },
    },
    after = function()
      require("overseer").setup({
        dap = false,
        task_list = {
          bindings = {
            ["<C-h>"] = false,
            ["<C-j>"] = false,
            ["<C-k>"] = false,
            ["<C-l>"] = false,
          },
        },
        form = {
          win_opts = {
            winblend = vim.g.floating_window_options.winblend,
          },
        },
        confirm = {
          win_opts = {
            winblend = vim.g.floating_window_options.winblend,
          },
        },
        task_win = {
          win_opts = {
            winblend = vim.g.floating_window_options.winblend,
          },
        },
      })

      -- Snacks notification integration for task completion
      vim.api.nvim_create_autocmd("User", {
        pattern = "OverseerTaskUpdate",
        callback = function(args)
          local task = args.data
          if task and task.is_final then
            local level = vim.log.levels.INFO
            local icon = "✓"

            if task.status == require("overseer").STATUS.FAILURE then
              level = vim.log.levels.ERROR
              icon = "✗"
            elseif task.status == require("overseer").STATUS.CANCELED then
              level = vim.log.levels.WARN
              icon = "⊘"
            end

            vim.notify(string.format("%s Task '%s' completed", icon, task.name), level, { title = "Overseer" })
          end
        end,
      })
    end,
    wk = {
      { "<leader>o", group = "overseer" },
    },
  },
}
