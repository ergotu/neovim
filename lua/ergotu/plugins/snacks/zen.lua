return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>uz",
        function()
          ---@diagnostic disable-next-line: missing-fields
          Snacks.zen({ win = { width = 0.65 } })
        end,
        desc = "Toggle Zen Mode",
      },
    },
  },
}
