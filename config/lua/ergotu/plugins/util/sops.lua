return {
  {
    "nvim-sops",
    cmd = { "SopsEncrypt", "SopsDecrypt" },
    after = function()
      require("sops-nvim").setup({
        -- Prevent leaking secrets
        debug = false,
        defaults = {
          ageKeyFile = "/Users/Jordi/.config/sops/age/keys.txt",
        },
      })

      -- Disable swap/undo for encrypted buffers
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.sops.*",
        callback = function()
          vim.opt_local.swapfile = false
          vim.opt_local.undofile = false
          vim.opt_local.backup = false
          vim.opt_local.writebackup = false
        end,
      })
    end,
  },
}
