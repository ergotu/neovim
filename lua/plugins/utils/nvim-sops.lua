return {
  "lucidph3nx/nvim-sops",
  cmd = { "SopsEncrypt", "SopsDecrypt" },
  opts = {
    debug = false,
    defaults = {
      ageKeyFile = "/Users/Jordi/.config/sops/age/keys.txt",
    },
  },
}
