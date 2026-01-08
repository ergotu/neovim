return {
  {
    "hunk.nvim",
    cmd = { "DiffEditor" },
    after = function()
      require("hunk").setup()
    end,
  },
}
