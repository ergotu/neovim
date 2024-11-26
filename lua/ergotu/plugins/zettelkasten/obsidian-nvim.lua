return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>z", group = "zettelkasten", icon = { icon = "󰪶 ", color = "cyan" } },
      },
    },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/vaults/personal/*.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/vaults/personal/*.md",
      "BufReadPre " .. vim.fn.expand("~") .. "/vaults/aws-for-developers/*.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/vaults/aws-for-developers/*.md",
    },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>zd",
        "<cmd>ObsidianToday<cr>",
        desc = "Daily",
      },
      {
        "<leader>zg",
        "<cmd>ObsidianSearch<cr>",
        desc = "Grep",
      },
      -- {
      --   "<leader>zf",
      --   "<cmd>ObsidianSearch<cr>",
      --   desc = "Find Note",
      -- },
      {
        "<leader>zn",
        "<cmd>ObsidianNew<cr>",
        desc = "New Note",
      },
      {
        "<leader>zb",
        "<cmd>ObsidianBacklinks<cr>",
        desc = "Backlinks",
      },
      {
        "<leader>zw",
        "<cmd>ObsidianWorkspace<cr>",
        desc = "Workspaces",
      },
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
        {
          name = "aws-for-developers",
          path = "~/vaults/aws-for-developers",
          overrides = {
            preferred_link_style = "markdown",
            note_id_func = function(title)
              return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            end,
            disable_frontmatter = true,
          },
        },
        {
          name = "no-vault",
          path = function()
            return assert(Util.root.cwd())
          end,
          overrides = {
            notes_subdit = vim.NIL, -- Have to use vim.NIL instead of 'nil'
            new_notes_location = "current_dir",
            templates = {
              folder = vim.NIL,
            },
            disable_frontmatter = true,
          },
        },
      },
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", "")
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,
    },
  },
  {
    "blink.cmp",
    sources = {
      completion = {
        enabled_providers = { "obsidian", "obsidian_new", "obsidian_tags" },
      },
      providers = {
        obsidian = {
          name = "obsidian",
          module = "blink.compat.source",
        },
        obsidian_tags = {
          name = "obsidian_tags",
          module = "blink.compat.source",
        },
        obsidian_new = {
          name = "obsidian_new",
          module = "blink.compat.source",
        },
      },
    },
  },
}
