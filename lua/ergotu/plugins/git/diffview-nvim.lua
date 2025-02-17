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
        desc = "Repo History (HEAD)",
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
          vim.cmd("DiffviewOpen origin/" .. get_default_branch_name() .. "..HEAD")
        end,
        desc = "Diff against origin/master",
      },
      {
        "<leader>gD",
        function()
          vim.cmd("DiffviewOpen")
        end,
        desc = "Open Diffview",
      },
    },
    cmd = "DiffviewOpen",
    opts = function()
      local actions = require("diffview.actions")

      require("diffview.ui.panel").Panel.default_config_float.border = "rounded"

      return {
        default_args = { DiffviewFileHistory = { "%" } },
        icons = {
          folder_closed = Util.config.icons.kinds.Folder,
          folder_open = "󰝰",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "",
        },
        enhanced_diff_hl = true,
        use_icons = true,
        view = {
          default = {
            disable_diagnostics = true,
          },
          merge_tool = {
            layout = "diff3_mixed",
          },
        },
        file_panel = {
          win_config = {
            position = "bottom",
            height = 10,
          },
        },
        file_history_panel = {
          win_config = {
            type = "split",
            position = "bottom",
            height = 10,
          },
        },
        -- stylua: ignore start
        keymaps = {
          disable_defaults = true,
          view = {
            { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
            { "n", "<C-f>", actions.toggle_files, { desc = "Toggle the file panel" } },
            { "n", "[F", actions.select_first_entry, { desc = "Open the diff for the first file" } },
            { "n", "]F", actions.select_last_entry, { desc = "Open the diff for the last file" } },
            { "n", "[x", actions.prev_conflict, { desc = "Merge-tool: jump to the previous conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Merge-tool: jump to the next conflict" } },
            { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
            { "n", "co", actions.conflict_choose("ours"), { desc = "Choose conflict --ours" } },
            { "n", "ct", actions.conflict_choose("theirs"), { desc = "Choose conflict --theirs" } },
            { "n", "cb", actions.conflict_choose("base"), { desc = "Choose conflict --base" } },
            { "n", "cd", actions.conflict_choose("none"), { desc = "Delete conflict region" } },
            { "n", "cO", actions.conflict_choose_all("ours"), { desc = "Choose conflict --ours for the whole file" } },
            { "n", "cT", actions.conflict_choose_all("theirs"), { desc = "Choose conflict --theirs for the whole file" } },
            { "n", "cB", actions.conflict_choose_all("base"), { desc = "Choose conflict --base for the whole file" } },
            ["gq"] = function()
              if vim.fn.tabpagenr("$") > 1 then
                vim.cmd.DiffviewClose()
              else
                vim.cmd.quitall()
              end
            end,
            unpack(actions.compat.fold_cmds),
          },
          diff2 = {
            { "n", "?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
            { "n", "++", "]c" },
            { "n", "--", "[c" },
          },
          diff3 = {
            { "n", "?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
            { "n", "++", "]c" },
            { "n", "--", "[c" },
          },
          file_panel = {
            { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>", actions.select_next_entry, { desc = "Select the next file entry" } },
            { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<up>", actions.select_prev_entry, { desc = "Select the previous file entry" } },
            { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
            { "n", "<C-f>", actions.toggle_files, { desc = "Toggle the file panel" } },
            { "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage the selected entry" } },
            { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
            { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
            { "n", "c-", actions.prev_conflict, { desc = "Go to prev conflict" } },
            { "n", "c+", actions.next_conflict, { desc = "Go to next conflict" } },
            { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
            { "n", "co", actions.conflict_choose_all("ours"), { desc = "Choose conflict --ours" } },
            { "n", "ct", actions.conflict_choose_all("theirs"), { desc = "Choose conflict --theirs" } },
            { "n", "cb", actions.conflict_choose_all("base"), { desc = "Choose conflict --base" } },
            { "n", "<Right>", actions.open_fold, { desc = "Expand fold" } },
            { "n", "<Left>", actions.close_fold, { desc = "Collapse fold" } },
            { "n", "l", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
            { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
            { "n", "?", actions.help("file_panel"), { desc = "Open the help panel" } },
            ["gq"] = function()
              if vim.fn.tabpagenr("$") > 1 then
                vim.cmd.DiffviewClose()
              else
                vim.cmd.quitall()
              end
            end,
            {
              "n",
              "cc",
              function()
                vim.ui.input({ prompt = "Commit message: " }, function(msg)
                  if not msg then
                    return
                  end
                  local results = vim.system({ "git", "commit", "-m", msg }, { text = true }):wait()
                  vim.notify(results.stdout, vim.log.levels.INFO, { title = "Commit", render = "simple" })
                end)
              end,
            },
            {
              "n",
              "cx",
              function()
                local results = vim.system({ "git", "commit", "--amend", "--no-edit" }, { text = true }):wait()
                vim.notify(results.stdout, vim.log.levels.INFO, { title = "Commit amend", render = "simple" })
              end,
            },
          },
          file_history_panel = {
            { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next log entry" } },
            { "n", "<down>", actions.select_next_entry, { desc = "Select the next log entry" } },
            { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous log entry." } },
            { "n", "<up>", actions.select_prev_entry, { desc = "Select the previous file entry." } },
            { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
            { "n", "gd", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
            { "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
            { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
            { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
            { "n", "?", actions.help("file_history_panel"), { desc = "Open the help panel" } },
            ["gq"] = function()
              if vim.fn.tabpagenr("$") > 1 then
                vim.cmd.DiffviewClose()
              else
                vim.cmd.quitall()
              end
            end,
          },
          option_panel = {
            { "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
            { "n", "q", actions.close, { desc = "Close the panel" } },
            { "n", "?", actions.help("option_panel"), { desc = "Open the help panel" } },
          },
          help_panel = {
            { "n", "q", actions.close, { desc = "Close help menu" } },
          },
        },
        -- stylua: ignore end
      }
    end,
  },
}
