return {
  {
    "olimorris/codecompanion.nvim",
    event = "LazyFile",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      log_level = "DEBUG",
      strategies = {
        chat = {
          adapter = "sonnet",
          slash_commands = {
            ["help"] = {
              opts = {
                provider = "snacks", -- fzf_lua or snacks
              },
            },
          },
        },
        inline = {
          adapter = "sonnet",
        },
      },
      adapters = {
        sonnet = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api/v1",
              chat_url = "/chat/completions",
              api_key = "cmd:bw get password 682e0747-0176-47fd-9254-aaa61ad8579d",
            },
            schema = {
              model = {
                default = "anthropic/claude-3.7-sonnet",
              },
            },
          })
        end,
        flash = function()
          return require("codecompanion.adapters").extend("gemini", {
            name = "flash",
            schema = {
              model = {
                default = "gemini-1.5-flash",
              },
            },
          })
        end,
      },
    },
  },
}
