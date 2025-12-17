local state = require("lz.n.handler.state").new()

local M = {
  spec_field = "wk",
  add = function(plugin)
    if not plugin.wk then
      return
    end
    state.insert(plugin)
    Snacks.util.on_module("which-key", function()
      require("which-key").add(plugin.wk)
    end)
  end,
  del = state.del,
  lookup = state.lookup_plugin,
}

return M
