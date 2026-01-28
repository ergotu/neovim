return {
  {
    "opencode.nvim",
    before = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- port = 54403,
        ask = {
          -- snacks = {
          --   icon = "💬 ",
          -- }
        },
        select = {
          -- prompt = 'meow',
          sections = {
            commands = {
              -- ['meowwww'] = 'MEOW MEOW',
              -- ['session.list'] = 'List Sessions',
            },
          },
        },
        provider = {
          -- enabled = false,
          cmd = "opencode --port",
          snacks = {
            auto_insert = true,
            -- win = {
            --   position = 'left'
            -- }
          },
        },
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true

      -- Recommended/example keymaps.
      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        require("opencode").ask(nil, { submit = true })
      end, { desc = "Ask opencode" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })

      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "opencode half page up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "opencode half page down" })

      -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  },
}
