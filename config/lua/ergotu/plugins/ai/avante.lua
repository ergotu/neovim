return {
  {
    "avante.nvim",
    enabled = false,
    event = "DeferredUIEnter",
    after = function()
      ---@module 'avante'
      ---@type avante.Config
      require("avante").setup({
        -- for example
        provider = "opencode",
        -- providers = {
        --   claude = {
        --     endpoint = "https://api.anthropic.com",
        --     model = "claude-sonnet-4-20250514",
        --     timeout = 30000, -- Timeout in milliseconds
        --     extra_request_body = {
        --       temperature = 0.75,
        --       max_tokens = 20480,
        --     },
        --   },
        --   moonshot = {
        --     endpoint = "https://api.moonshot.ai/v1",
        --     model = "kimi-k2-0711-preview",
        --     timeout = 30000, -- Timeout in milliseconds
        --     extra_request_body = {
        --       temperature = 0.75,
        --       max_tokens = 32768,
        --     },
        --   },
        -- },
        --
        acp_providers = {
          ["opencode"] = {
            command = "opencode",
            args = { "acp" },
          },
        },
        input = {
          provider = "snacks",
          provider_opts = {
            -- Additional snacks.input options
            title = "Avante Input",
            icon = " ",
          },
        },
      })
    end,
  },
}
