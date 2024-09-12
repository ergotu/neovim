return {
  {
    "aznhe21/actions-preview.nvim",
    config = true,
    keys = {
      {
        "ga",
        function()
          require("actions-preview").code_actions()
        end,
        mode = { "n", "v" },
        desc = "Preview Code Actions",
      },
    },
  },
}
