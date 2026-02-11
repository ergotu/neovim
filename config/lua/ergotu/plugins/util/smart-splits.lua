return {
  {
    "smart-splits.nvim",
    event = "DeferredUIEnter",
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
        "<C-Left>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Go to Left Window",
      },
      {
        "<C-Down>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Go to Lower Window",
      },
      {
        "<C-Up>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Go to Upper Window",
      },
      {
        "<C-Right>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Go to Right Window",
      },
      {
        "<C-S-Left>",
        function()
          require("smart-splits").resize_left()
        end,
        desc = "Decrease Window Width",
      },
      {
        "<C-S-Down>",
        function()
          require("smart-splits").resize_down()
        end,
        desc = "Decrease Window Height",
      },
      {
        "<C-S-Up>",
        function()
          require("smart-splits").resize_up()
        end,
        desc = "Increase Window Height",
      },
      {
        "<C-S-Right>",
        function()
          require("smart-splits").resize_right()
        end,
        desc = "Increase Window Width",
      },
    },
    after = function()
      require("smart-splits").setup()
    end,
  },
}
