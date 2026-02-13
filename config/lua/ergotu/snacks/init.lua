-- lua/ergotu/snacks/init.lua
local M = {}

-- Terminal navigation helper
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and ("<c-" .. dir .. ">") or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
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

  -- Register keymaps
  require("ergotu.snacks.keymaps").set()

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
