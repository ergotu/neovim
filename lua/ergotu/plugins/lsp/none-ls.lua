return {
  -- none-ls
  {
    "nvimtools/none-ls.nvim",
    priority = 100,
    event = "LazyFile",
    dependencies = {
      {
        "mason.nvim",
      },
    },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.fish,
      })
    end,
  },
}
