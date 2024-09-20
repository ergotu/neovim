return {
  {
    "mistricky/codesnap.nvim",
    build = "make",
    cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapSaveHighlight", "CodeSnapASCII" },
    keys = function()
      local wk = require("which-key")
      wk.add({
        {
          mode = { "x" },
          {
            "<leader>cs",
            "<Esc><cmd>CodeSnap<cr>",
            icon = "󰄀",
            desc = "CodeSnap to Clipboard",
          },
          {
            "<leader>cS",
            "<Esc><cmd>CodeSnapSave<cr>",
            icon = "󰄀",
            desc = "CodeSnap to File",
          },
          {
            "<leader>ch",
            "<Esc><cmd>CodeSnapHighlight<cr>",
            icon = "󰄀",
            desc = "CodeSnap Highlight to Clipboard",
          },
          {
            "<leader>cH",
            "<Esc><cmd>CodeSnapSaveHighlight<cr>",
            icon = "󰄀",
            desc = "CodeSnap Highlight to File",
          },
        },
      })
    end,
    opts = {
      mac_window_bar = false,
      has_breadcrumbs = true,
      show_workspace = true,
      watermark = "",
      bg_padding = 0,
      code_font_family = "FiraCode Nerd Font",
      has_line_number = true,
    },
  },
}
