local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1

local function open(builtin, opts)
  opts = opts or {}
  opts.follow = opts.follow ~= false
  if opts.cwd and opts.cwd ~= vim.uv.cwd() then
    local function open_cwd_dir()
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      open(
        builtin,
        vim.tbl_deep_extend("force", {}, opts or {}, {
          root = false,
          default_text = line,
        })
      )
    end
    ---@diagnostic disable-next-line: inject-field
    opts.attach_mappings = function(_, map)
      -- opts.desc is overridden by telescope, until it's changed there is this fix
      map("i", "<a-c>", open_cwd_dir, { desc = "Open cwd Directory" })
      return true
    end
  end

  require("telescope.builtin")[builtin](opts)
end

local function telescope(command, opts)
  opts = opts or {}
  return function()
    command = command ~= "auto" and command or "find_files"
    opts = opts or {}
    opts = vim.deepcopy(opts)

    if not opts.cwd and opts.root ~= false then
      opts.cwd = Util.root({ buf = opts.buf })
    end

    open(command, vim.deepcopy(opts))
  end
end
return {
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = have_make and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = have_make or have_cmake,
        config = function(plugin)
          Util.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (Util.is_win() and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                Util.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  Util.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                end)
              else
                Util.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
              end
            end
          end)
        end,
      },
    },
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/", telescope("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader><space>", telescope("find_files"), desc = "Find Files (Root Dir)" },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      {
        "<leader>fc",
        telescope("find_files", { cwd = vim.fn.stdpath("config") }),
        desc = "Find Config File",
      },
      { "<leader>ff", telescope("find_files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", telescope("find_files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", telescope("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      {
        "<leader>fw",
        function()
          telescope("find_files", { default_text = vim.fn.expand("<cword>") })()
        end,
        desc = "Find Files (Current word)",
      },
      -- git
      { "<leader>gC", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", telescope("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", telescope("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", telescope("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
      { "<leader>sW", telescope("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
      { "<leader>sw", telescope("grep_string"), mode = "v", desc = "Selection (Root Dir)" },
      { "<leader>sW", telescope("grep_string", { root = false }), mode = "v", desc = "Selection (cwd)" },
      {
        "<leader>uC",
        telescope("colorscheme", { enable_preview = true }),
        desc = "Colorscheme with Preview",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = Util.config.get_kind_filter(),
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = Util.config.get_kind_filter(),
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.sources.telescope").open(...)
      end

      local find_files_no_ignore = function(...)
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        require("telescope.builtin").find_files({ no_ignore = true, default_text = line })
      end

      local find_files_with_hidden = function(...)
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        require("telescope.builtin").find_files({ hidden = true, default_text = line })
      end

      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end

      local function find_command()
        if 1 == vim.fn.executable("rg") then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif 1 == vim.fn.executable("fd") then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("fdfind") then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
          return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable("where") then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<c-s>"] = flash,
            },
            n = {
              ["q"] = actions.close,
              ["s"] = flash,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
      }
    end,
  },

  {
    "debugloop/telescope-undo.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
        dependencies = {
          {
            "nvim-lua/plenary.nvim",
          },
        },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>su",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      extensions = {
        undo = {
          side_by_side = true,
          layout_strategy = "vertical",
          layout_config = {
            preview_height = 0.8,
          },
        },
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function()
      local Keys = require("ergotu.util.lsp.keymaps").get()
      -- stylua: ignore
      vim.list_extend(Keys, {
        { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition", has = "definition" },
        { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
        { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
        { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
      })
    end,
  },
}
