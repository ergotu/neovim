{
  description = "Provide nixosModules for ergotu/neovim";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs = {nixpkgs.follows = "nixpkgs";};
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      imports = [
        inputs.devenv.flakeModule
      ];

      flake = {
        homeManagerModules = {
          nvimdots = ./nixos;
        };
      };

      systems = ["aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        system,
        pkgs,
        ...
      }: let
        extraPackages = [
          pkgs.ast-grep
          pkgs.doq
          pkgs.tree-sitter
          pkgs.cargo
          pkgs.zig
          pkgs.cmake
          pkgs.curl
          pkgs.fd
          pkgs.gcc
          pkgs.git
          pkgs.gnumake
          pkgs.go
          pkgs.lua51Packages.luarocks
          pkgs.ninja
          pkgs.ripgrep
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

              -- lazy.nvim resets rtp for performance reasons, so we need to pass the path of the configuration
              vim.g.rtp_path = "${./.}"
              -- add source to rtp_path so we can load our configuration
              vim.opt.rtp:append(vim.g.rtp_path)

              -- load configuration
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
        packages = {
          default = self.packages.${system}.neovim;

          neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
        };

        devenv.shells.default = {
          pre-commit = {
            src = ./.;
            hooks = {
              statix.enable = true;
              alejandra.enable = true;
              stylua.enable = true;
              commitizen.enable = true;
            };
          };

          languages = {
            nix = {
              enable = true;
              lsp.package = pkgs.nixd;
            };
            lua.enable = true;
          };

          packages = [
            # LUA LSP and tools
            pkgs.lua-language-server
            pkgs.stylua
            pkgs.selene

            # Nix LSP and formatter
            pkgs.nixd
            pkgs.alejandra

            pkgs.gcc
            pkgs.cmake
          ];
        };
      };
    };
}
