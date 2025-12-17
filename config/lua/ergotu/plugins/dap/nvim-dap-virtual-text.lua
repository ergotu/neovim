---@type lz.n.Spec[]
return {
  {
    "nvim-dap-virtual-text",
    event = "DeferredUIEnter",
    after = function()
      local config = require("ergotu.config.debugging").config
      require("nvim-dap-virtual-text").setup({
        enabled = config.virtual_text.enabled,
        commented = config.virtual_text.commented,
        virt_text_pos = "eol",
        all_frames = false,
        virt_lines = false,
      })
    end,
  },
}
