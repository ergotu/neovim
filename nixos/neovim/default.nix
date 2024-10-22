# home-manager module of neovim setup
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.neovim.nvimdots;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) listOf package;
in {
  options = {
    programs.neovim = {
      nvimdots = {
        enable = mkEnableOption ''
          Activate dotfiles for neovim
        '';
        bindLazyLock = mkEnableOption ''
          Bind lazy-lock.json in your repository to $XDG_CONFIG_HOME/nvim.
          Very powerful in terms of keeping the environment consistent, but has the following side effects.
          You cannot update it even if you run the Lazy command, because it binds read-only.
          You need to remove lazy-lock.json before enabling this option if `mergeLazyLock` is set.
        '';
        mergeLazyLock = mkEnableOption ''
          Merges the managed lazy-lock.json with the existing one under $XDG_CONFIG_HOME/nvim if its hash has changed on activation.
          Upstream package version changes have high priority.
          This means changes to lazy-lock.json in the config directory (likely due to installing package) will be preserved.
          In other words, it achieves environment consistency while remaining adaptable to changes.
          You need to unlink lazy-lock.json before enabling this option if `bindLazyLock` is set.
          Please refer to the wiki for details on the behavior.
        '';
        withBuildTools = mkEnableOption ''
          Include basic build tools like `gcc` and `pkg-config`.
          Required for NixOS.
        '';
        extraDependentPackages = mkOption {
          type = listOf package;
          default = [];
          example = literalExpression "[ pkgs.openssl ]";
          description = "Extra build depends to add `LIBRARY_PATH` and `CPATH`.";
        };
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = ! (cfg.bindLazyLock && cfg.mergeLazyLock);
        message = "bindLazyLock and mergeLazyLock cannot be enabled at the same time.";
      }
    ];
    xdg.configFile =
      {
        "nvim/init.lua".source = ../../init.lua;
        "nvim/lua".source = ../../lua;
      }
      // optionalAttrs cfg.bindLazyLock {
        "nvim/lazy-lock.json".source = ../../lazy-lock.json;
      }
      // optionalAttrs cfg.mergeLazyLock {
        "nvim/lazy-lock.fixed.json" = {
          source = ../../lazy-lock.json;
          onChange = ''
            if [ -f ${config.xdg.configHome}/nvim/lazy-lock.json ]; then
              tmp=$(mktemp)
              ${pkgs.jq}/bin/jq -r -s '.[0] * .[1]' ${config.xdg.configHome}/nvim/lazy-lock.json ${config.xdg.configFile."nvim/lazy-lock.fixed.json".source} > "''${tmp}" && mv "''${tmp}" ${config.xdg.configHome}/nvim/lazy-lock.json
            else
              ${pkgs.rsync}/bin/rsync --chmod 644 ${config.xdg.configFile."nvim/lazy-lock.fixed.json".source} ${config.xdg.configHome}/nvim/lazy-lock.json
            fi
          '';
        };
      };
    home = {
      packages = [
        pkgs.ripgrep
      ];
    };
    programs.neovim = {
      enable = true;

      withNodeJs = true;
      withPython3 = true;

      extraPackages =
        [
          # Dependent packages used by default plugins
          pkgs.doq
          pkgs.tree-sitter
        ]
        ++ optionals cfg.withBuildTools [
          pkgs.cargo
          pkgs.zig
          pkgs.cmake
          pkgs.gcc
          pkgs.gnumake
          pkgs.go
          pkgs.lua51Packages.luarocks
          pkgs.ninja
          pkgs.pkg-config
          pkgs.yarn
        ];

      extraPython3Packages = ps:
        with ps; [
          docformatter
          isort
          pynvim
        ];
    };
  };
}
