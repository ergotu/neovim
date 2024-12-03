return {
  "echasnovski/mini.indentscope",
  version = false, -- wait till new 0.7.0 release to put it back on semver
  event = "LazyFile",
  opts = {
    -- symbol = "▏",
    symbol = "▎",
    options = { try_as_border = true },
    draw = {
      delay = 100,
      priority = 2,
      animation = function(s, n)
        return s / n * 20
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "alpha",
        "snacks_dashboard",
        "fzf",
        "help",
        "lazy",
        "snacks_terminal",
        "snacks_win",
        "mason",
        "neo-tree",
        "notify",
        "Trouble",
        "trouble",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}
