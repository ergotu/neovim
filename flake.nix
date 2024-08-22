{
  description = "Provide nixosModules for ergotu/neovim";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
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
      }: {
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
            mkShell {inherit (self'.checks.pre-commit-check) shellHook;};
        };
      };
    };
}
