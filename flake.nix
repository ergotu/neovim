{
  description = "Provide nixosModules for ergotu/neovim";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      type = "github";
      owner = "nix-community";
      repo = "neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    flake-utils,
    neovim-nightly,
    pre-commit-hooks,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      flake = {
        homeManagerModules = {
          nvimdots = ./nixos;
        };
      };

      systems = ["aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        system,
        pkgs,
        self',
        ...
      }: let
        extraPackages = [
          # Dependent packages used by default plugins
          pkgs.doq
          pkgs.tree-sitter
          pkgs.cargo
          pkgs.clang
          pkgs.cmake
          pkgs.gcc
          pkgs.gnumake
          pkgs.go
          pkgs.lua51Packages.luarocks
          pkgs.ninja
          pkgs.pkg-config
          pkgs.yarn
        ];
        packagesPath = pkgs.lib.makeBinPath extraPackages;

        initFile = pkgs.writeTextFile {
          name = "init.lua";
          text =
            #lua
            ''
              vim.loader.enable()
              vim.opt.rtp:append("${./.}")
              vim.g.rtp_path = "${./.}"
              require("ergotu")
            '';
        };

        neovimConfig =
          pkgs.neovimUtils.makeNeovimConfig {
            customRC = "luafile ${initFile}";
          }
          // {
            viAlias = true;
            vimAlias = true;
            withNodeJs = false;
            withPython3 = false;
            withRuby = false;
            wrapperArgs = pkgs.lib.escapeShellArgs ["--suffix" "PATH" ":" "${packagesPath}"];
          };
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              statix.enable = true;
              alejandra.enable = true;
              stylua.enable = true;
            };
          };
        };

        packages = {
          default = self.packages.${system}.neovim;

          neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
        };

        devShells = {
          default = with pkgs;
            mkShell {inherit (self'.checks.pre-commit-check) shellHook;};
        };
      };
    };
}
