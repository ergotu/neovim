vim.loader.enable()
vim.opt.exrc = false

if vim.env.PROF then
  require("snacks.profiler").startup({
    startup = {
      event = "UIEnter",
    },
    presets = {
      startup = {
        min_time = 0,
      },
    },
  })
end

-- No remote plugins
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require("ergotu")
