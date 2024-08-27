# Neovim config

This is my neovim config, usable with both normal systems, as well as packaged as a nix flake.

If you have nix installed and want to try this configuration out you can run the following command

```bash
nix run github:ergotu/neovim
```

This configuration is probably overkill, and took a LOT of inspiration from LazyVim.

## Usage on a non nix managed system

Simply copy (or symlink) this folder to `~/.config/nvim/`

## Usage with home-manager

Add this repo as an input to your flake

- flake.nix:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      nixpkgs.follows = "nixpkgs";
    };
    nvimdots = {
      url = "github:ergotu/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
  }
  # ...
}
```

- neovim.nix:

```nix
{nvimdots, ...}: {
  imports = [nvimdots.homeManagerModules.nvimdots];

  programs.neovim.nvimdots = {
    enable = true;
    # withBuildTools is only necessary on NixOS systems
    withBuildTools = true;
  };
}
```

If this is running on a NixOS system `mason.nvim` and `mason-lspconfig.nvim` are automatically disabled.
The user is responsible for installing the necessary tools and LSPs.
