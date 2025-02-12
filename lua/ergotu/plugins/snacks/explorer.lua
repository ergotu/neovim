return {
  "folke/snacks.nvim",
  opts = {
    explorer = {},
    picker = {
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["s"] = "edit_split",
                ["v"] = "edit_vsplit",
              },
            },
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        ---@diagnostic disable-next-line: missing-fields
        Snacks.explorer({ cwd = Util.root() })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
  },
}
