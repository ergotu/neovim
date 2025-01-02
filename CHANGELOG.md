## 2.1.0 (2025-01-02)

### Feat

- add image support
- **keymaps**: add extra toggles for snacks features

## 2.0.0 (2024-12-19)

### Feat

- **snacks**: use snacks for maximize
- **lualine**: add snacks profiler status
- **git**: change keymaps for branch/blame
- **blink**: change blink config to work on main
- **ui**: switch picker to fzf-lua
- **snacks**: add debugger keymaps
- **keymap**: allow stopping snippet with esc
- add health check
- **blink**: increase lazydev score
- **autocmds**: add autocmd to set up folding
- **autocmds**: write to ShaDa on buffer delete
- **snacks**: replace ibl and indentscope for the snacks version
- **keymaps**: add keymap to open lazygit
- **zen**: replace zen-mode.nvim with snacks zen mode

### Fix

- **blink**: only override color symbol kind
- **fzf**: fix git commits keymap
- **keymaps**: cmd -> noh
- **lang/lua**: increase score for lazydev
- **refactoring**: explicitly pass empty opts
- **neogit**: disable auto_show_console
- **blink**: use vim.snippet fix
- **autocmds**: fix the treesitter folding autocmd
- **lsp**: actually check for nvim 11 for lsp folding

### Refactor

- **util.ui**: add comments and use local var

## 1.2.0 (2024-12-11)

### Feat

- **snacks**: add profiler
- **snacks**: have snacks deal with LspProgress notifications
- **keymaps**: add keymap to duplicate line and comment out first

### Fix

- **neogit**: disable foldexpr when ft is neogitconsole
- **dot**: kitty ft with bash treesitter
- **treesitter**: change incremental_selection keymap
- **keymaps**: move to the safe_keymap_set function

## 1.1.0 (2024-12-06)

### Feat

- **keymaps**: add keymap to duplicate line and comment out first
- **keymaps**: add tabline toggle
- **flake**: add gcc and update inputs

### Fix

- **treesitter**: change incremental_selection keymap
- **keymaps**: move to the safe_keymap_set function
- **treesitter**: disable treesitter in neogitconsole
- **blink**: update config for latest version
- **indentscope**: add extra autocmd to disable on snacks_dashboard

## 1.0.0 (2024-12-05)

### Feat

- **lsp**: add the option to use lsp folding
- **lsp**: add tiny-inline-diagnostic for displaying diagnostic messages
- **gitsigns**: make blame instant
- **diffview**: add DiffviewOpen keymap
- **snacks**: add additional keymaps
- **lang/typescript**: limit max length of inlayHints
- **lang**: add zig support
- add treesitter highlights
- **dotnet**: switch to csharp-language-server
- **blink.cmp**: set draw for autocomplete close to old reversed
- **misc**: forgot to commit this
- **keymaps**: add keymap to copy gitbrowse url
- **snacks**: use snacks dashboard instead of dashboard.nvim
- **catppuccin**: enable snacks integration
- **blink**: enable blink.compat and sources when needed
- **eslint**: add option to disable eslint autoformat
- **terraform**: add formatter for packer files
- **keymaps**: use snacks to delete other buffers
- **snacks**: change statuscolumn fold options
- **opts**: remove bigfile_size in favour of using snacks
- **snacks**: remove util.toggle class
- **snacks**: add debugging commands
- **blink**: make keymaps more explicit
- **snacks**: use toggle
- **snacks**: use terminal
- **snacks**: use gitbrowse
- **snacks**: use rename
- **snacks**: use words
- **snacks**: use statuscolumn
- **snacks**: use bufremove
- **snacks**: use bigfile
- **snacks**: use quickfile
- **snacks**: add snacks to replace some utility functions
- **noice**: set default border and style for hover windows
- **blink**: add ripgrep provider/source
- **obsidian-nvim**: add aws-for-developers vault
- **blink**: add blink as potential replacement for nvim-cmp
- **lang.rust**: enable crates.nvim in process lsp
- **nvim-cmp**: use root.cwd as cwd function for rg
- **nvim-cmp**: set priorities
- **keymaps**: add split lines function and mapping
- **wezterm-types**: add wezterm-types for my wezterm config
- **neogit**: switch to neogit fork
- **quickfix**: add quickfix filetype config
- **help**: add help filetype config
- **git**: add git filetype config
- **go**: add GoModTidy command
- **snippets**: add js/ts snippets
- **completion**: switch to magazine
- **noice.nvim**: add extra routes
- **gitsigns**: add extra config for current line blame
- **diffview.nvim**: change configuration
- **neogit**: use neogit for git log instead of gitgraph.nvim
- **catppuccin**: dim inactive windows
- **lsp**: use builtin lsb hover provider
- **util.format**: add FormatInfo user command to show active formatters
- **yanky**: add yanky.nvim
- **keymaps**: add better yank and delete keymaps
- **rust**: update rustaceanvim
- **util.toggle**: add more customization options
- **ui**: add rainbow-delimiters.nvim
- add initial zettelkasten setup
- **nvim-notify**: lazy load if noice isnt enabled
- **python**: add black as formatter
- set up prettier so it only runs if we have config for it
- **json**: recognize some files known to have comments
- **lightbulb**: add lightbulb that signifies available code actions
- **util.root**: handle workspace folders provided by lsp
- add initial dictionary
- **util.root**: add option to ignore LSP in root detection
- **snippets**: add lua snippets
- **util.root**: add vcs detector
- **util.root**: add info command to help with debugging detectors
- **noice.nvim**: add additional filters
- add codesnap for pretty code screenshots
- **avante.nvim**: configure avante to use local llm and enable
- add gitgraph.nvim
- **mini.indentscope**: add custom draw animation
- change keymaps related to git to make more sense in my head
- add ftplugins
- add extra git related keymaps
- add additional blame keybinds for gitsigns
- add adopure for ADO PRs
- **gitsigns**: add keymap to preview hunk in floating window
- **telescope**: add keymap to find file based on current word
- add markview.nvim as optional alternative to render-markdown
- **lualine**: disable trouble component and move attached clients
- **neo-tree**: refresh git status when closing neogit windows
- add attached clients to lualine
- add octo
- add neogit configuration
- define more diff related keymappings
- add additional git tools
- I derped somewhere and lost my local commits
- add hardtime
- **lang**: add ansible and terraform
- add python support
- change buffer source in nvim_cmp
- add dotnet support
- switch from navigator.nvim to smart-splits.nvim
- switch to nixd
- use the same floating window options everywhere
- add avante.nvim (not loaded for now)
- lazy load clipboard setting
- add arrow.nvim
- add option to run flake as standalone
- initial commit

### Fix

- **flake**: add cmake to shell
- **ui**: disable indentscope on snacks_dashboard
- **blink**: update blink for new config
- **avante**: use api_key_name instead of local
- **catppuccin**: remove unused integrations
- **snacks**: explicitly enable plugins
- **lazydev**: use luals bundled luv library
- **dial.nvim**: add bool and logical toggles to default group
- **telescope**: ignore current buffer in find buffer keymap
- **opts**: disable default ruler
- **lsp**: wrap hover and signature help
- **opts**: enable spelling in regular text files
- **terraform**: lazy load telescope terraform plugins
- **lualine**: normalize paths before calculating pretty path
- **blink**: add escape keymap to hide completion without leaving insert
- **util.cmp**: use filetype to disable buffer source instead of size
- **telescope**: check for gmake
- **lualine**: apply hl correctly to pretty_paths
- **snacks**: add snacks_win to close_with_q
- **util.lualine**: ensure path in root before substitute
- **opts**: set default pumblend to 10
- **markdown**: fix render-markdown not loading in md files
- **autocmds**: vim.highlight is getting deprecated
- **util.root**: move from vim.loop vim.uv
- **nvim-dap**: remove explicit load_launchjs call
- **autocmds**: close window and force delete buffer on q
- **smart-splits-nvim**: load on VeryLazy event
- **nvim-dap**: properly get the icons from config
- remove newlines that caused references to fail to be resolved
- **noice**: disable lsp hover
- **neotest**: properly initialize adapters
- remove redundant file types
- add ast-grep to the extrapackages for nvim
- **markdown**: load obsidian.nvim properly
- **noice.nvim**: only use vim.notify for error messages
- **json**: have hujso be recognized as json with comments
- load order was wrong for lazy loading clipboard
- **mini.files**: disable preview and hardtime
- reorder init steps
- **util.root**: handle multiple lsp servers
- **cmp**: better c-n and c-p fallback
- remove unnecessary binds
- **util.root**: use Util to show the output instead of just printing it
- **noice.nvim**: viewWarn was nix convention
- add additional dependencies
- **hardtime**: disable in gitsigns buffers
- add git as extra package
- nvim_get_hl_by_name is deprecated
- change gitsigns bindings to use the lua api
- enable integrations in neogit
- import ordering problem
- **markdown**: only load obsidian when in vault
- **markdown**: unknown function
- use open instead of deprecated method
- allow trailing commas in hujson files
- change tsserver to ts_ls
- **style**: set more borders to rounded
- conform.nvim deprecated nested brackets
- remove pre-commit file that should not have been committed in the first place

### Refactor

- **util.ui**: update the maximize code
- **util.ui**: simplify ui.fg
- **noice.nvim**: move away from using the preset lsp doc border
- change root util

### Perf

- **treesitter**: improve foldexpr
- **ui**: disable treesitter folds if the buffer has no highlighting
