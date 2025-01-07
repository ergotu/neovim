return {
  -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  {
    "folke/noice.nvim",
    priority = 100,
    event = "VeryLazy",
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        message = {
          enabled = true,
        },
        hover = {
          enabled = false,
        },
        signature = {
          enabled = not Util.has("blink.cmp"),
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "fewer lines" },
              { find = "written" },
              { find = "Conflict %[%d+" },
              { find = "Col %d+" },
            },
          },
          view = "mini",
        },
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = {
            skip = true,
          },
        },
        { filter = { event = "msg_show", find = "search hit BOTTOM" }, skip = true },
        { filter = { event = "msg_show", find = "search hit TOP" }, skip = true },
        { filter = { event = "emsg", find = "E23" }, skip = true },
        { filter = { event = "emsg", find = "E20" }, skip = true },
        { filter = { find = "No signature help" }, skip = true },
        { filter = { find = "E37" }, skip = true },
        { filter = { find = "E31" }, skip = true },
        { filter = { find = "E162" }, view = "mini" },
        { filter = { find = "Error detected while processing BufReadPost Autocommands for" }, skip = true },
      },
      messages = {
        enabled = true,
      },
      notify = {
        enabled = true,
      },
      views = {
        hover = {
          border = {
            style = vim.g.floating_window_options.border,
          },
          position = {
            row = 2,
            col = 2,
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>sn",  "",                                                                            desc = "+noice" },
      { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                 mode = "c",                 desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end,                                   desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end,                                desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end,                                    desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end,                                desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>",       function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,  silent = true,              expr = true,              desc = "Scroll forward",  mode = { "i", "n", "s" } },
      { "<c-b>",       function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true,              expr = true,              desc = "Scroll backward", mode = { "i", "n", "s" } },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled
      -- but this is not ideal when Lazy is installing plugins
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },
}
