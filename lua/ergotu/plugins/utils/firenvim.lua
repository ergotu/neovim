if not vim.g.started_by_firenvim then
  return {
    {
      "glacambre/firenvim",
      lazy = true,
      module = false,
      build = function()
        require("lazy").load({ plugins = { "firenvim" } })
        vim.fn["firenvim#install"](0)
      end,
    },
  }
end

local enabled = {
  "dial.nvim",
  "lazy.nvim",
  "flash.nvim",
  "mini.ai",
  "mini.comment",
  "mini.move",
  "mini.pairs",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  "snacks.nvim",
  "ts-comments.nvim",
  "yanky.nvim",
  "which-key.nvim",
  "catppuccin",
  "firenvim",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name)
end

local filetype_map = {
  ["github.com"] = "markdown",
  ["cocalc.com"] = "python",
  ["kaggleusercontent.com"] = "python",
  ["localhost"] = "python",
  ["reddit.com"] = "markdown",
  ["stackexchange.com"] = "markdown",
  ["stackoverflow.com"] = "markdown",
  ["slack.com"] = "markdown",
  ["gitter.com"] = "markdown",
}

local special_cases = {
  ["riot.im"] = function()
    vim.cmd("normal! i")
    vim.api.nvim_set_keymap(
      "i",
      "<CR>",
      '<Esc>:w<CR>:call firenvim#press_keys("<LT>CR>")<CR>ggdGa',
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap("i", "<S-CR>", "<CR>", { noremap = true, silent = true })
  end,
}

local function set_filetype(bufname)
  for pattern, filetype in pairs(filetype_map) do
    if bufname:match(pattern) then
      vim.opt.filetype = filetype
      break
    end
  end
end

local function handle_special_cases(bufname)
  for pattern, action in pairs(special_cases) do
    if bufname:match(pattern) then
      action()
      break
    end
  end
end

return {
  {
    "snacks.nvim",
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
    },
  },
  {
    "glacambre/firenvim",
    lazy = false,
    priority = 100,
    module = false,
    opts = {
      localSettings = {
        [ [[.*]] ] = {
          cmdline = "firenvim",
          priority = 0,
          selector = 'textarea:not([readonly]):not([class="handsontableInput"]), div[role="textbox"]',
          takeover = "always",
        },
        [ [[.*notion\.so.*]] ] = {
          priority = 9,
          takeover = "never",
        },
        [ [[.*docs\.google\.com.*]] ] = {
          priority = 9,
          takeover = "never",
        },
      },
    },
    config = function(_, opts)
      if type(opts) == "table" and (opts.localSettings or opts.globalSettings) then
        vim.g.firenvim_config = opts
      end
    end,
    init = function()
      vim.api.nvim_create_augroup("firenvim", { clear = true })

      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = "firenvim",
        callback = function()
          if vim.g.timer_started then
            return
          end
          vim.g.timer_started = true
          vim.fn.timer_start(10000, function()
            vim.g.timer_started = false
            vim.cmd("silent write")
          end)
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        group = "firenvim",
        callback = function(args)
          local bufname = vim.api.nvim_buf_get_name(args.buf)

          set_filetype(bufname)
          handle_special_cases(bufname)
        end,
      })

      vim.g.snacks_animate = false
      vim.o.laststatus = 0
    end,
  },
}
