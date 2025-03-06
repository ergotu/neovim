return {
  {
    "xzbdmw/clasp.nvim",
    opts = {},
    keys = {
      {
        "<c-l>",
        function()
          require("clasp").wrap("next")
        end,
        mode = { "n", "i" },
        desc = "Move pair forward",
      },
    },
  },
}
