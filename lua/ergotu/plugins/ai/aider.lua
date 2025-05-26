return {
  {
    "GeorgesAlkhouri/nvim-aider",
    dependencies = {
      "folke/snacks.nvim",
    },
    cmd = {
      "Aider",
      "AiderHealth",
    },
    keys = {
      { "<leader>aa/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
      { "<leader>aaa", "<leader>aa/", desc = "Toggle Aider", remap = true },
      { "<leader>aas", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>aac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
      { "<leader>aab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
      { "gaa", "<cmd>Aider add<cr>", desc = "Add File" },
      { "gad", "<cmd>Aider drop<cr>", desc = "Drop File" },
      { "gar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
    },
    opts = {
      args = {
        "--no-auto-commits",
        "--pretty",
        "--stream",
        "--watch",
        "--model openrouter/google/gemini-2.5-pro-preview-03-25",
        -- "--architect",
        -- "--model openrouter/r1",
        -- "--editor-model openrouter/sonnet",
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
