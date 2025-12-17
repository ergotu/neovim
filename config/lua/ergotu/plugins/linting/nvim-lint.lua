---@type lz.n.Spec[]
return {
  {
    "nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      local config = require("ergotu.config.linting").config
      local lint = require("lint")

      -- Configure linters
      lint.linters_by_ft = config.linters_by_ft

      -- Apply linter overrides
      for name, linter in pairs(config.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end

      local function try_lint()
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)
        names = vim.list_extend({}, names or {})

        -- Only extend if the table exists
        if #names == 0 and lint.linters_by_ft["_"] then
          vim.list_extend(names, lint.linters_by_ft["_"])
        end
        if lint.linters_by_ft["*"] then
          vim.list_extend(names, lint.linters_by_ft["*"])
        end

        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            vim.notify(string.format("Warning: Linter not found '%s'", name), vim.log.levels.WARN)
          end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        if #names > 0 then
          lint.try_lint(names)
        end
      end

      -- Autocommands to trigger linting
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("ergovim_lint", { clear = true }),
        callback = Snacks.util.debounce(try_lint, { ms = 100 }),
      })
    end,
  },
}
