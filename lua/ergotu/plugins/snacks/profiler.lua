return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>dps",
        function()
          Snacks.profiler.scratch()
        end,
        desc = "Profiler Scratch Bufer",
      },
    },
  },
}
