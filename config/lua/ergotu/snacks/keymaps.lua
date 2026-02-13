-- lua/ergotu/snacks/keymaps.lua
local M = {}

-- Helper function to get current working directory
local function get_cwd()
  return vim.fn.getcwd()
end

-- Keymap definitions organized by category
-- Each entry: { mode, lhs, rhs_or_fn, desc, opts? }
local keymaps = {
  -- Notifications
  notifications = {
    {
      "n",
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      "Notification History",
    },
    {
      "n",
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      "Dismiss All Notifications",
    },
  },

  -- Scratch
  scratch = {
    {
      "n",
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      "Toggle Scratch Buffer",
    },
    {
      "n",
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      "Select Scratch Buffer",
    },
  },

  -- Zen Mode
  zen = {
    {
      "n",
      "<leader>uz",
      function()
        Snacks.zen({ win = { width = 0.65 } })
      end,
      "Zen Mode",
    },
  },

  -- Profiler
  profiler = {
    {
      "n",
      "<leader>dps",
      function()
        Snacks.profiler.scratch()
      end,
      "Profiler Scratch Buffer",
    },
  },

  -- Explorer
  explorer = {
    {
      "n",
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = Ergovim.root.get() })
      end,
      "Explorer Snacks (root dir)",
    },
    {
      "n",
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      "Explorer Snacks (cwd)",
    },
    { "n", "<leader>e", "<leader>fe", "Explorer Snacks (root dir)", { remap = true } },
    { "n", "<leader>E", "<leader>fE", "Explorer Snacks (cwd)", { remap = true } },
  },

  -- Picker: General
  picker_general = {
    {
      "n",
      "<leader>,",
      function()
        Snacks.picker.buffers()
      end,
      "Buffers",
    },
    {
      "n",
      "<leader>/",
      function()
        Snacks.picker.grep({ cwd = Ergovim.root.get() })
      end,
      "Grep (Root Dir)",
    },
    {
      "n",
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      "Command History",
    },
    {
      "n",
      "<leader><space>",
      function()
        Snacks.picker.smart({ cwd = Ergovim.root.get() })
      end,
      "Smart Picker (Buffers/Recent/Files)",
    },
  },

  -- Picker: Find
  picker_find = {
    {
      "n",
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      "Buffers",
    },
    {
      "n",
      "<leader>fB",
      function()
        Snacks.picker.buffers({ hidden = true, nofile = true })
      end,
      "Buffers (all)",
    },
    {
      "n",
      "<leader>fc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      "Find Config File",
    },
    {
      "n",
      "<leader>ff",
      function()
        Snacks.picker.files({ cwd = Ergovim.root.get() })
      end,
      "Find Files (Root Dir)",
    },
    {
      "n",
      "<leader>fF",
      function()
        Snacks.picker.files({ cwd = get_cwd() })
      end,
      "Find Files (cwd)",
    },
    {
      "n",
      "<leader>fg",
      function()
        Snacks.picker.git_files()
      end,
      "Find Files (git-files)",
    },
    {
      "n",
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      "Recent",
    },
    {
      "n",
      "<leader>fR",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      "Recent (cwd)",
    },
    {
      "n",
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      "Projects",
    },
  },

  -- Picker: Git
  picker_git = {
    {
      "n",
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      "Git Status",
    },
    {
      "n",
      "<leader>gS",
      function()
        Snacks.picker.git_stash()
      end,
      "Git Stash",
    },
  },

  -- Picker: Grep
  picker_grep = {
    {
      "n",
      "<leader>sb",
      function()
        Snacks.picker.lines()
      end,
      "Buffer Lines",
    },
    {
      "n",
      "<leader>sB",
      function()
        Snacks.picker.grep_buffers()
      end,
      "Grep Open Buffers",
    },
    {
      "n",
      "<leader>sg",
      function()
        Snacks.picker.grep({ cwd = Ergovim.root.get() })
      end,
      "Grep (Root Dir)",
    },
    {
      "n",
      "<leader>sG",
      function()
        Snacks.picker.grep({ cwd = get_cwd() })
      end,
      "Grep (cwd)",
    },
    {
      { "n", "x" },
      "<leader>sw",
      function()
        Snacks.picker.grep_word({ cwd = Ergovim.root.get() })
      end,
      "Visual selection or word (Root Dir)",
    },
    {
      { "n", "x" },
      "<leader>sW",
      function()
        Snacks.picker.grep_word({ cwd = get_cwd() })
      end,
      "Visual selection or word (cwd)",
    },
  },

  -- Picker: Search
  picker_search = {
    {
      "n",
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      "Registers",
    },
    {
      "n",
      "<leader>s/",
      function()
        Snacks.picker.search_history()
      end,
      "Search History",
    },
    {
      "n",
      "<leader>sa",
      function()
        Snacks.picker.autocmds()
      end,
      "Autocmds",
    },
    {
      "n",
      "<leader>sc",
      function()
        Snacks.picker.command_history()
      end,
      "Command History",
    },
    {
      "n",
      "<leader>sC",
      function()
        Snacks.picker.commands()
      end,
      "Commands",
    },
    {
      "n",
      "<leader>sd",
      function()
        Snacks.picker.diagnostics()
      end,
      "Diagnostics",
    },
    {
      "n",
      "<leader>sD",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      "Buffer Diagnostics",
    },
    {
      "n",
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      "Help Pages",
    },
    {
      "n",
      "<leader>sH",
      function()
        Snacks.picker.highlights()
      end,
      "Highlights",
    },
    {
      "n",
      "<leader>si",
      function()
        Snacks.picker.icons()
      end,
      "Icons",
    },
    {
      "n",
      "<leader>sj",
      function()
        Snacks.picker.jumps()
      end,
      "Jumps",
    },
    {
      "n",
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      "Keymaps",
    },
    {
      "n",
      "<leader>sl",
      function()
        Snacks.picker.loclist()
      end,
      "Location List",
    },
    {
      "n",
      "<leader>sM",
      function()
        Snacks.picker.man()
      end,
      "Man Pages",
    },
    {
      "n",
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      "Marks",
    },
    {
      "n",
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      "Resume",
    },
    {
      "n",
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      "Quickfix List",
    },
    {
      "n",
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      "Undotree",
    },
  },

  -- UI
  ui = {
    {
      "n",
      "<leader>uC",
      function()
        Snacks.picker.colorschemes()
      end,
      "Colorschemes",
    },
  },

  -- Jujutsu
  jujutsu = {
    {
      "n",
      "<leader>jj",
      function()
        Snacks.terminal.open("jjui", {
          win = { height = 0.6, width = 0.8, border = true },
          interactive = true,
        })
      end,
      "jjui",
    },
  },
}

--- Register all keymaps
function M.set()
  Snacks = require("snacks")
  for _, category in pairs(keymaps) do
    for _, entry in ipairs(category) do
      local mode, lhs, rhs, desc, opts = entry[1], entry[2], entry[3], entry[4], entry[5] or {}
      opts.desc = desc
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end
end

return M
