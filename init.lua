-- The existence of the /etc/NIXOS file officializes that it is a NixOS partition
vim.g.nix = vim.loop.fs_stat("/etc/NIXOS") and true or false

require("ergotu")
