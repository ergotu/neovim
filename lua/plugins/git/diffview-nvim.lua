local function get_default_branch_name()
  local res = vim.system({ "git", "rev-parse", "--verify", "main" }, { capture_output = true }):wait()
  return res.code == 0 and "main" or "master"
end

return {
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gdh",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Repo History",
      },
      {
        "<leader>gdf",
        "<cmd>DiffviewFileHistory --follow %<cr>",
        desc = "File History",
      },
      {
        "<leader>gdl",
        "<cmd>.DiffviewFileHistory --follow<cr>",
        desc = "Line History",
      },
      {
        "<leader>gdl",
        mode = { "v" },
        "<cmd>'<,'>DiffviewFileHistory --follow<cr>",
        desc = "Range History",
      },
      {
        "<leader>gdH",
        "<cmd>DiffviewOpen<cr>",
        desc = "Repo History",
      },
      {
        "<leader>gdm",
        function()
          vim.cmd("DiffviewOpen " .. get_default_branch_name())
        end,
        desc = "Diff against master",
      },
      {
        "<leader>gdM",
        function()
          vim.cmd("DiffviewOpen HEAD..origin/" .. get_default_branch_name())
        end,
        desc = "Diff against origin/master",
      },
    },
    opts = {},
  },
}
