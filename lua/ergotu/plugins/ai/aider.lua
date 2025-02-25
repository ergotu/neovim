return {
  {
    "GeorgesAlkhouri/nvim-aider",
    dependencies = {
      "folke/snacks.nvim",
    },
    cmd = {
      "AiderTerminalToggle",
      "AiderHealth",
    },
    keys = {
      { "<leader>aa/", "<cmd>AiderTerminalToggle<cr>", desc = "Toggle Aider" },
      { "<leader>aaa", "<leader>aa/", desc = "Toggle Aider", remap = true },
      { "<leader>aas", "<cmd>AiderTerminalSend<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>aac", "<cmd>AiderQuickSendCommand<cr>", desc = "Send Command To Aider" },
      { "<leader>aab", "<cmd>AiderQuickSendBuffer<cr>", desc = "Send Buffer To Aider" },
      { "gaa", "<cmd>AiderQuickAddFile<cr>", desc = "Add File to Aider" },
      { "gad", "<cmd>AiderQuickDropFile<cr>", desc = "Drop File from Aider" },
      { "gar", "<cmd>AiderQuickReadOnlyFile<cr>", desc = "Add File as Read-Only" },
    },
    opts = {
      args = {
        "--no-auto-commits",
        "--pretty",
        "--stream",
        "--watch",
      },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "AI" },
        { "<leader>aa", group = "Aider" },
        { "ga", group = "Aider" },
      },
    },
  },
}
