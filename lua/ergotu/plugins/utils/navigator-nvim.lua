return {
  {
    "dynamotn/Navigator.nvim",
    enabled = true,
    opts = {
      disable_on_zoom = true,
    },
    keys = {
      {
        "<C-h>",
        "<CMD>NavigatorLeft<CR>",
        desc = "Go to Left Window",
      },
      {
        "<C-j>",
        "<CMD>NavigatorDown<CR>",
        desc = "Go to Lower Window",
      },
      {
        "<C-k>",
        "<CMD>NavigatorUp<CR>",
        desc = "Go to Upper Window",
      },
      {
        "<C-l>",
        "<CMD>NavigatorRight<CR>",
        desc = "Go to Right Window",
      },
    },
  },
}
