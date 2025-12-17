return {
  {
    "inc-rename.nvim",
    cmd = "IncRename",
    -- beforeAll = function()
    --   local lsp = require("ergotu.config.lsp")
    --   lsp.add_server("*", {
    --     keys = {
    --       {
    --         "<leader>cr",
    --         function()
    --           local inc_rename = require("inc_rename")
    --           return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
    --         end,
    --         expr = true,
    --         desc = "Rename (inc-rename.nvim)",
    --         has = "rename",
    --       },
    --     },
    --   })
    -- end,
    after = function()
      require("inc_rename").setup({})
    end,
  },
}
