return {
  {
    "flash.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    vscode = true,
    after = function()
      require("flash").setup({
        labels = "arstgmneioqwfpbjluyzxcdvkh", -- colemak-dh
      })
    end,
    -- stylua: ignore
    keys = {
      { "s",      mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",      mode = { "n", "o", "x" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",      mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",      mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>",  mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
}
