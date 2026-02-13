-- lua/config/snacks.lua
local M = {}

-- Helper function to get current working directory
local function get_cwd()
  return vim.fn.getcwd()
end

-- Terminal navigation helper
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and ("<c-" .. dir .. ">") or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
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
local function set_keys()
  Snacks = require("snacks")
  for _, category in pairs(keymaps) do
    for _, entry in ipairs(category) do
      local mode, lhs, rhs, desc, opts = entry[1], entry[2], entry[3], entry[4], entry[5] or {}
      opts.desc = desc
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end
end

function M.setup()
  local Snacks = require("snacks")

  Snacks.setup({
    bigfile = { enabled = true },
    dashboard = {
      preset = {
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "w", desc = "Worktrees", action = ":WorktreeSwitch" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
          { icon = " ", key = ".", desc = "Restore Session", action = function() require("persistence").load() end },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
      },
    },
    explorer = {
      replace_netrw = true,
    },
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      win = {
        input = {
          keys = {
            ["<a-c>"] = { "toggle_cwd", mode = { "n", "i" } },
            ["s"] = "edit_split",
            ["v"] = "edit_vsplit",
            ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
            ["<a-s>"] = { "flash", mode = { "n", "i" } },
            ["S"] = { "flash" },
          },
        },
      },
      actions = {
        ---@param p snacks.Picker
        toggle_cwd = function(p)
          local root = Ergovim.root.get({ buf = p.input.filter.current_buf })
          local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
          local current = p:cwd()
          p:set_cwd(current == root and cwd or root)
          p:find()
        end,
        trouble_open = function(...)
          return require("trouble.sources.snacks").actions.trouble_open.action(...)
        end,
        flash = function(picker)
          require("flash").jump({
            pattern = "^",
            label = { after = { 0, 0 } },
            search = {
              mode = "search",
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["s"] = "edit_split",
                ["v"] = "edit_vsplit",
              },
            },
          },
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = {
      folds = {
        open = true,
        git_hl = true,
      },
    },
    terminal = {
      ---@diagnostic disable-next-line: missing-fields
      win = {
        height = 0.2,
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          nav_left = { "<C-left>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_down = { "<C-down>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_up = { "<C-up>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_right = { "<C-right>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        },
      },
    },
    words = { enabled = true },
  })

  set_keys()

  -- Setup globals for debugging
  vim.api.nvim_create_autocmd("User", {
    pattern = "DeferredUIEnter",
    callback = function()
      _G.dd = function(...)
        Snacks.debug.inspect(...)
      end
      _G.bt = function()
        Snacks.debug.backtrace()
      end
      vim.print = _G.dd -- Override print to use snacks for := command
    end,
  })
end

return M
