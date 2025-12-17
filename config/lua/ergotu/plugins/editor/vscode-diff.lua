local function get_default_branch_name()
  local res = vim.system({ "git", "rev-parse", "--verify", "main" }, { capture_output = true }):wait()
  return res.code == 0 and "main" or "master"
end

return {
  {
    "vscode-diff.nvim",
    cmd = "CodeDiff",
    keys = {
      -- Repo diff (working tree explorer)
      {
        "<leader>gD",
        "<cmd>CodeDiff<cr>",
        desc = "Open CodeDiff (working tree vs HEAD)",
      },
      -- Keep your Diffview naming: "Repo History (HEAD)" ~= open diff vs HEAD
      {
        "<leader>gdH",
        "<cmd>CodeDiff<cr>",
        desc = "Repo Diff (HEAD)",
      },

      -- Diff against default branch (main/master) and origin/<default>
      {
        "<leader>gdm",
        function()
          local b = get_default_branch_name()
          -- Compare two revisions: <base> <target>
          vim.cmd(("CodeDiff %s HEAD"):format(b))
        end,
        desc = "Diff against main/master (..HEAD)",
      },
      {
        "<leader>gdM",
        function()
          local b = get_default_branch_name()
          vim.cmd(("CodeDiff origin/%s HEAD"):format(b))
        end,
        desc = "Diff against origin/main|master (..HEAD)",
      },

      -- Current file diff
      {
        "<leader>gdf",
        "<cmd>CodeDiff file HEAD<cr>",
        desc = "Diff current file vs HEAD",
      },
      {
        "<leader>gdF",
        function()
          local b = get_default_branch_name()
          vim.cmd(("CodeDiff file %s HEAD"):format(b))
        end,
        desc = "Diff current file vs main/master (..HEAD)",
      },
    },

    config = function()
      require("vscode-diff").setup({
        -- Highlight configuration
        highlights = {
          -- Line-level: accepts highlight group names or hex colors (e.g., "#2ea043")
          line_insert = "DiffAdd", -- Line-level insertions
          line_delete = "DiffDelete", -- Line-level deletions

          -- Character-level: accepts highlight group names or hex colors
          -- If specified, these override char_brightness calculation
          char_insert = nil, -- Character-level insertions (nil = auto-derive)
          char_delete = nil, -- Character-level deletions (nil = auto-derive)

          -- Brightness multiplier (only used when char_insert/char_delete are nil)
          -- nil = auto-detect based on background (1.4 for dark, 0.92 for light)
          char_brightness = nil, -- Auto-adjust based on your colorscheme
        },

        -- Diff view behavior
        diff = {
          disable_inlay_hints = true, -- Disable inlay hints in diff windows for cleaner view
          max_computation_time_ms = 5000, -- Maximum time for diff computation (VSCode default)
          hide_merge_artifacts = false, -- Hide merge tool temp files (*.orig, *.BACKUP.*, *.BASE.*, *.LOCAL.*, *.REMOTE.*)
        },

        -- Keymaps in diff view
        keymaps = {
          view = {
            quit = "q", -- Close diff tab
            toggle_explorer = "<leader>b", -- Toggle explorer visibility (explorer mode only)
            next_hunk = "]c", -- Jump to next change
            prev_hunk = "[c", -- Jump to previous change
            next_file = "]f", -- Next file in explorer mode
            prev_file = "[f", -- Previous file in explorer mode
          },
          explorer = {
            select = "<CR>", -- Open diff for selected file
            hover = "K", -- Show file diff preview
            refresh = "R", -- Refresh git status
          },
          conflict = {
            accept_incoming = "<leader>ct", -- Accept incoming (theirs/left) change
            accept_current = "<leader>co", -- Accept current (ours/right) change
            accept_both = "<leader>cb", -- Accept both changes (incoming first)
            discard = "<leader>cx", -- Discard both, keep base
            next_conflict = "]x", -- Jump to next conflict
            prev_conflict = "[x", -- Jump to previous conflict
          },
        },
      })
    end,
  },
}
