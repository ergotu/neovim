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
  };

  outputs = inputs @ {
    self,
    flake-parts,
    flake-utils,
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

        devShells = {
          default = with pkgs;
            mkShell {
              inherit (self'.checks.pre-commit-check) shellHook;
              packages = [
                self'.packages.default

                # LUA LSP and tools
                pkgs.lua-language-server
                pkgs.stylua
                pkgs.selene

                # Nix LSP and formatter
                pkgs.nil
                pkgs.alejandra
              ];
            };
        };
      };
    };
}
