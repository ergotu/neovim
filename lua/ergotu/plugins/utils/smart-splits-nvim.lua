return {
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Go to Left Window",
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Go to Lower Window",
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Go to Upper Window",
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Go to Right Window",
      },
      {
        "<C-left>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Go to Left Window",
      },
      {
        "<C-down>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Go to Lower Window",
      },
      {
        "<C-up>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Go to Upper Window",
      },
      {
        "<C-right>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Go to Right Window",
      },
      {
        "<C-S-left>",
        function()
          require("smart-splits").resize_left()
        end,
        desc = "Go to Left Window",
      },
      {
        "<C-S-down>",
        function()
          require("smart-splits").resize_down()
        end,
        desc = "Go to Lower Window",
      },
      {
        "<C-S-up>",
        function()
          require("smart-splits").resize_up()
        end,
        desc = "Go to Upper Window",
      },
      {
        "<C-S-right>",
        function()
          require("smart-splits").resize_right()
        end,
        desc = "Go to Right Window",
      },
    },
    opts = {},
  },
}
