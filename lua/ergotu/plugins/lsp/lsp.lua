local methods = vim.lsp.protocol.Methods
return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      {
        "williamboman/mason-lspconfig.nvim",
        enabled = not vim.g.nix,
        event = "VeryLazy",
        config = function() end,
      },
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {

        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = not Util.has("tiny-inline-diagnostic.nvim") and {
            spacing = 4,
            source = "if_many",
            prefix = "icons",
          } or false,
          float = {
            border = vim.g.floating_window_options.border,
          },
          virtual_lines = false,
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = Util.config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = Util.config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = Util.config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = Util.config.icons.diagnostics.Info,
            },
          },
        },
        -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the inlay hints.
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the code lenses.
        codelens = {
          enabled = true,
          throttle = 1000, -- Time in ms to throttle refreshes (default: 250)
          events = { "BufEnter", "CursorHold", "InsertLeave" }, -- Events that trigger refresh
          -- Set events = {} to disable automatic refreshes entirely
        },
        folding = {
          enabled = true,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        lightbulb = true,
        -- LSP Server Settings
        ---@type lspconfig.options
        ---@diagnostic disable-next-line: missing-fields
        servers = {},
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- setup keymaps
      Util.lsp.on_attach(function(client, buffer)
        Util.lsp.keymaps.on_attach(client, buffer)
      end)

      -- setup lightbulb
      if opts.lightbulb then
        Util.lsp.on_supports_method(methods.textDocument_codeAction, function(client, buffer)
          Util.lsp.lightbulb.on_attach(buffer, client.id)
        end)
      end

      -- set up border for hover and signatureHelp
      Util.lsp.on_attach(function(_, _)
        vim.lsp.handlers[methods.textDocument_hover] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = vim.g.floating_window_options.border,
        })
        vim.lsp.handlers[methods.textDocument_signatureHelp] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = vim.g.floating_window_options.border,
        })
      end)

      -- set up document colour highlighting
      if vim.fn.has("nvim-0.12") == 1 then
        Util.lsp.on_supports_method(methods.textDocument_documentColor, function(_, buffer)
          vim.lsp.document_color.enable(true, buffer)
        end)
      end

      Util.lsp.setup()
      Util.lsp.on_dynamic_capability(Util.lsp.on_attach)

      -- inlay hints
      if opts.inlay_hints.enabled then
        Util.lsp.on_supports_method(methods.textDocument_inlayHint, function(_, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Util.lsp.on_supports_method(methods.textDocument_codeLens, function(_, buffer)
          -- Configuration options with defaults
          local throttle_ms = opts.codelens.throttle or 250
          local events = opts.codelens.events or { "BufEnter", "CursorHold", "InsertLeave" }

          -- Skip setup if no events are configured
          if vim.tbl_isempty(events) then
            return
          end

          -- Create a throttled version of the refresh function
          local timer = vim.uv.new_timer()
          local debouncing = false

          local throttled_refresh = function()
            if not debouncing then
              debouncing = true
              timer:start(throttle_ms, 0, function()
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(buffer) then
                    vim.lsp.codelens.refresh({ bufnr = buffer })
                  end
                  debouncing = false
                end)
              end)
            end
          end

          -- Cleanup timer when buffer is unloaded
          vim.api.nvim_create_autocmd("BufUnload", {
            buffer = buffer,
            callback = function()
              if timer and not timer:is_closing() then
                timer:close()
              end
            end,
          })

          -- Initial refresh
          vim.lsp.codelens.refresh({ bufnr = buffer })

          -- Setup autocommands with throttling
          vim.api.nvim_create_autocmd(events, {
            buffer = buffer,
            callback = throttled_refresh,
          })
        end)
      end

      -- LSP folding
      if opts.folding.enabled and vim.fn.has("nvim-0.11") == 1 then
        Util.lsp.on_supports_method(methods.textDocument_foldingRange, function(_, _)
          vim.wo[0][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end)
      end

      if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
        opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
          or function(diagnostic)
            local icons = Util.config.icons.diagnostics
            for d, icon in pairs(icons) do
              if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                return icon
              end
            end
          end
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        if server_opts.enabled == false then
          return
        end

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            -- run manual setup if mason=false, if this is a server that cannot be installed with mason-lspconfig, or if mason is not enabled
            if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) or not have_mason then
              setup(server)
            else
              ensure_installed[#ensure_installed + 1] = server
            end
          end
        end
      end

      if have_mason then
        ---@diagnostic disable-next-line: missing-fields
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend(
            "force",
            ensure_installed,
            Util.opts("mason-lspconfig.nvim").ensure_installed or {}
          ),
          handlers = { setup },
        })
      end

      if Util.lsp.is_enabled("denols") and Util.lsp.is_enabled("vtsls") then
        local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
        Util.lsp.disable("vtsls", is_deno)
        Util.lsp.disable("denols", function(root_dir, config)
          if not is_deno(root_dir) then
            config.settings.deno.enable = false
          end
          return false
        end)
      end
    end,
  },
}
