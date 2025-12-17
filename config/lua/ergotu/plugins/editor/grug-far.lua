return {
  {
    "grug-far.nvim",
    after = function()
      require("grug-far").setup({ headerMaxWidth = 80 })
    end,
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", "", desc = "Search and Replace" },
      {
        "<leader>srR",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
      {
        "<leader>srr",
        function()
          local grug = require("grug-far")
          grug.open({
            transient = true,
            prefills = {
              paths = vim.fn.expand("%"),
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (Current File)",
      },
      {
        "<leader>srw",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              search = vim.fn.expand("<cword>"),
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (Word)",
      },
      {
        "<leader>srW",
        function()
          local grug = require("grug-far")
          grug.open({
            transient = true,
            prefills = {
              paths = vim.fn.expand("%"),
              search = vim.fn.expand("<cword>"),
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (Word in Current File)",
      },
    },
  },
}
