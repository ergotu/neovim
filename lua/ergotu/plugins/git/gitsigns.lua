return {
  "lewis6991/gitsigns.nvim",
  event = "LazyFile",
  enabled = true,
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text_pos = "right_align",
    },
    preview_config = {
      border = vim.g.floating_window_options.border,
    },
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        -- Actions
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk Inline")
        map("n", "<leader>ghP", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gB", function() gs.blame() end, "Blame Buffer")

      -- Text Object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

       -- Toggles
        local config = require('gitsigns.config').config
        Util.toggle.map("<leader>gdd", {
        name = "Deleted",
        get = function()
          return require("gitsigns.config").config.show_deleted
        end,
        set = function (state)
          if state then
            gs.toggle_deleted(true)
          else
            gs.toggle_deleted(false)
          end
        end
        })
        Util.toggle.map("<leader>gdL", {
        name = "Line Hightlight",
        get = function()
          return config.linehl
        end,
        set = function (state)
          if state then
            gs.toggle_linehl(true)
          else
            gs.toggle_linehl(false)
          end
        end
        })
        Util.toggle.map("<leader>gdw", {
        name = "Word Hightlight",
        get = function()
          return config.word_diff
        end,
        set = function (state)
          if state then
            gs.toggle_word_diff(true)
          else
            gs.toggle_word_diff(false)
          end
        end
        })
    end,
  },
}
