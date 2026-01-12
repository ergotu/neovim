{
  description = "A custom neovim configuration flake using mnw";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mnw.url = "github:Gerg-L/mnw";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lzn-auto-require = {
      url = "github:horriblename/lzn-auto-require";
      flake = false;
    };

    direnv-nvim = {
      url = "github:NotAShelf/direnv.nvim";
      flake = false;
    };

    worktrees-nvim = {
      url = "github:ergotu/worktrees.nvim/next";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hunk-nvim = {
      url = "github:julienvincent/hunk.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    mnw,
    neovim-nightly-overlay,
    lzn-auto-require,
    direnv-nvim,
    worktrees-nvim,
    hunk-nvim,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-nightly = import nixpkgs {
          inherit system;
          overlays = [neovim-nightly-overlay.overlays.default];
        };

        # TODO: remove this when next is merged to main
        vscode-diff-nvim-next = pkgs.vimPlugins.vscode-diff-nvim.overrideAttrs (_: rec {
          version = "2.0.0-next.12";
          src = pkgs.fetchFromGitHub {
            owner = "esmuellert";
            repo = "vscode-diff.nvim";
            rev = "v${version}";
            hash = "sha256-IIZSG3PPgH7P2T36gyH7RXban6M+pMKKTxtCeSjFRA8=";
          };
        });

        runtimeDeps = with pkgs; [
          lazygit
          jjui

          # Telescope/file finders usually need these
          ripgrep
          fd

          # Common requirements
          git
          curl

          # Image utils
          imagemagick
          ghostscript
          tectonic
          nodePackages.mermaid-cli
        ];

        # Factory function to create ergovim with any Neovim version
        mkErgovim = nvimPkg:
          mnw.lib.wrap pkgs {
            neovim = nvimPkg;

            aliases = [
              "vi"
              "vim"
            ];

            providers = {
              nodeJs.enable = false;
              perl.enable = false;
              python3.enable = false;
              ruby.enable = false;
            };

            # Set custom app name
            appName = "ergovim";

            # Add runtime dependencies to PATH
            extraBinPath = runtimeDeps;

            plugins = with pkgs.vimPlugins; {
              # Plugins loaded immediately at startup
              start = [
                mini-icons
                flatten-nvim
                friendly-snippets
                snacks-nvim
                lz-n

                (pkgs.vimUtils.buildVimPlugin {
                  name = "lzn-auto-require";
                  src = lzn-auto-require;
                  doCheck = false;
                })
              ];
              startAttrs = {
                nvim-treesitter = null;
                lspconfig-nvim = null;
                nvim-dap = null;
                neotest = null;
              };

              # Plugins loaded lazily via lz.n
              opt = [
                # LSP
                lazydev-nvim
                lazy-lsp-nvim

                # Completion
                blink-cmp

                # Formatting & Linting
                conform-nvim
                nvim-lint

                # Debugging (DAP)
                nvim-dap
                nvim-dap-ui
                nvim-dap-virtual-text

                # Testing
                neotest
                neotest-go
                neotest-rust
                neotest-plenary
                neotest-jest
                neotest-vitest

                # Task runner
                overseer-nvim

                # Treesitter
                nvim-treesitter.withAllGrammars
                nvim-treesitter-context
                nvim-treesitter-textobjects
                nvim-ts-autotag
                treesj

                # Colorscheme
                catppuccin-nvim

                # UI
                bufferline-nvim
                lualine-nvim
                noice-nvim
                dropbar-nvim
                indent-blankline-nvim
                rainbow-delimiters-nvim

                # Editor
                flash-nvim
                grug-far-nvim
                smart-splits-nvim
                todo-comments-nvim
                ts-comments-nvim
                trouble-nvim
                inc-rename-nvim

                # Git
                neogit
                gitsigns-nvim
                diffview-nvim
                vscode-diff-nvim-next
                worktrees-nvim.packages.${system}.default
                (pkgs.vimUtils.buildVimPlugin {
                  name = "hunk.nvim";
                  src = hunk-nvim;
                  doCheck = false;
                })

                # Util
                which-key-nvim
                persistence-nvim
                nvim-sops
                (pkgs.vimUtils.buildVimPlugin {
                  name = "direnv.nvim";
                  src = direnv-nvim;
                  doCheck = false;
                })

                # Mini plugins
                mini-ai
                mini-surround
                mini-pairs
                mini-hipatterns

                # Language-specific
                SchemaStore-nvim # JSON/YAML schemas
                clangd_extensions-nvim # C/C++
                omnisharp-extended-lsp-nvim # C#
                markdown-preview-nvim # Markdown
                ansible-vim # Ansible
              ];

              # Development plugin for local configuration
              dev.ergovim-config = {
                pure = pkgs.lib.fileset.toSource {
                  root = ./config;
                  fileset = pkgs.lib.fileset.fromSource (pkgs.lib.sources.cleanSource ./config);
                };
                impure = "~/Documents/Projects/neovim/dev/config/";
              };
            };

            extraBuilderArgs = {
              doInstallCheck = false;
              installCheckPhase = ''
                export HOME="$(mktemp -d)"
                export NVIM_SILENT=1
                echo "Verifying Neovim configuration loads correctly..."

                # Capture output to variable
                output=$($out/bin/nvim --headless '+lua require("ergotu.health").loaded_exit()' '+q' 2>&1)
                exit_code=$?

                if [ $exit_code -ne 0 ]; then
                  echo "✗ Configuration failed to load"
                  echo "Error output:"
                  echo "$output"
                  exit 1
                else
                  echo "✓ Configuration loaded successfully"
                fi
              '';
            };
          };

        # Instantiate both stable and nightly variants
        ergovim = mkErgovim pkgs.neovim-unwrapped;
        ergovim-nightly = mkErgovim pkgs-nightly.neovim;
      in {
        default = ergovim;
        inherit ergovim ergovim-nightly;
      }
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        runtimeDeps = with pkgs; [
          # Language Servers (LSPs)
          lua-language-server
          nixd
          nil

          # Formatters
          alejandra
          stylua

          # Linters
          selene
          statix
          deadnix

          # Task runner
          just
        ];
      in {
        default = pkgs.mkShell {
          buildInputs =
            runtimeDeps
            ++ [
              # Include the dev mode Neovim with live config reloading
              self.packages.${system}.ergovim.devMode
            ];
        };
      }
    );
  };
}
