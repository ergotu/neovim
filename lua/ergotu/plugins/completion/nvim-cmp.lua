-- auto completion
return {
  "iguanacucumber/magazine.nvim",
  name = "nvim-cmp",
  version = false, -- last release is way too old
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-calc",
    "lukas-reineke/cmp-rg",
  },
  -- Not all LSP servers add brackets when completing a function.
  -- To better deal with this, we add a custom option to cmp,
  -- that you can configure. For example:
  --
  -- ```lua
  -- opts = {
  --   auto_brackets = { "python" }
  -- }
  -- ```
  opts = function()
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    local cmp = require("cmp")
    local defaults = require("cmp.config.default")()

    local auto_select = true
    local icons = Util.config.icons.kinds
    local widths = {
      abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
      menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
    }

    return {
      auto_brackets = {}, -- configure any filetype to auto add brackets
      completion = {
        completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = Util.cmp.confirm({ select = auto_select }),
        ["<C-y>"] = Util.cmp.confirm({ select = true }),
        ["<S-CR>"] = Util.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<C-CR>"] = function(fallback)
          cmp.abort()
          fallback()
        end,
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 500 },
        { name = "calc", priority = 200 },
        { name = "path", priority = 300 },
        { name = "rg", keyword_length = 3, option = { cwd = Util.root.cwd() }, priority = 400 },
      }, {
        Util.cmp.buffer_source,
      }),
      formatting = {
        format = function(_, item)
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end

          for key, width in pairs(widths) do
            if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
              item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
            end
          end

          return item
        end,
      },
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
      sorting = defaults.sorting,
    }
  end,
  config = function(_, opts)
    for _, source in ipairs(opts.sources) do
      source.group_index = source.group_index or 1
    end

    local cmp = require("cmp")
    cmp.setup(opts)
    cmp.event:on("confirm_done", function(event)
      if vim.tbl_contains(opts.auto_brackets or {}, vim.bo.filetype) then
        Util.cmp.auto_brackets(event.entry)
      end
    end)
    cmp.event:on("menu_opened", function(event)
      Util.cmp.add_missing_snippet_docs(event.window)
    end)
  end,
}
