---@class ergotu.util.langs
---@field lsp ergotu.util.langs.lsp
---@field formatting ergotu.util.langs.formatting
---@field linting ergotu.util.langs.linting
---@field debugging ergotu.util.langs.debugging
---@field testing ergotu.util.langs.testing
local M = {}

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ergotu.util.langs." .. k)
    return t[k]
  end,
})

return M
