return {
  {
    "Willem-J-an/adopure.nvim",
    cmd = "AdoPure",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      vim.g.adopure = {}
    end,
    keys = {
      { "<leader>gap", "<cmd>AdoPure load context<cr>", desc = "List PRs (ADO)" },
      { "<leader>gac", "<cmd>AdoPure submit comment<cr>", desc = "Submit Comment (ADO)" },
      { "<leader>gav", "<cmd>AdoPure submit vote<cr>", desc = "Submit Vote (ADO)" },
      { "<leader>gaT", "<cmd>AdoPure load threads<cr>", desc = "Load Threads (ADO)" },
      { "<leader>gaq", "<cmd>AdoPure open quickfix<cr>", desc = "Open Threads In Quickfix (ADO)" },
      { "<leader>gat", "<cmd>AdoPure open thread_picker<cr>", desc = "Open Thread Picker (ADO)" },
      { "<leader>gan", "<cmd>AdoPure open new_thread<cr>", mode = { "n", "v" }, desc = "Create new thread (ADO)" },
      { "<leader>gae", "<cmd>AdoPure open existing_thread<cr>", desc = "Open Existing Thread (ADO)" },
      { "<leader>gas", "<cmd>AdoPure submit thread_status<cr>", desc = "Change Thread Status (ADO)" },
    },
  },
}
