# Justfile for Neovim configuration development
# Run `just` or `just --list` to see all available tasks

# Set shell to bash for consistent behavior
set shell := ["bash", "-uc"]

# Variables
lua_dir := "config/lua"
nix_files := "flake.nix"
result_bin := "./result/bin/nvim"

# Default task: format, lint, build, and run health check
default: fmt lint build health
    @echo "✓ All checks passed!"

# ============================================================================
# Build Tasks
# ============================================================================

# Build the release version of Neovim
build:
    @echo "Building release version..."
    nix build

# Build with detailed error traces (useful for debugging build issues)
build-trace:
    @echo "Building with trace..."
    nix build --show-trace

# Build the development version with live config reloading
build-dev:
    @echo "Building dev version..."
    nix build .#ergovim.devMode

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf result result-*

# Rebuild and replace the current build
rebuild: clean build

# ============================================================================
# Run Tasks
# ============================================================================

# Run the built Neovim (release version)
run:
    @if [ ! -e "{{result_bin}}" ]; then \
        echo "Error: Built binary not found. Run 'just build' first."; \
        exit 1; \
    fi
    {{result_bin}}

# Run Neovim with debug logging enabled
run-debug: build
    @echo "Running with debug logging..."
    DEBUG_ERGOTU=1 {{result_bin}}

# Run Neovim with profiling enabled
run-prof: build
    @echo "Running with profiling..."
    PROF=1 {{result_bin}}

# Run the development version directly (no build)
run-dev:
    @echo "Running dev version..."
    nix run .#ergovim.devMode

# Open a specific file with the built Neovim
open FILE: build
    {{result_bin}} {{FILE}}

# ============================================================================
# Code Quality - Formatting
# ============================================================================

# Format all Lua files
fmt-lua:
    @echo "Formatting Lua files..."
    stylua {{lua_dir}}

# Format all Nix files
fmt-nix:
    @echo "Formatting Nix files..."
    alejandra {{nix_files}}

# Format all code (Lua and Nix)
fmt: fmt-lua fmt-nix
    @echo "✓ All files formatted"

# Check Lua formatting without modifying files
fmt-check-lua:
    @echo "Checking Lua formatting..."
    stylua --check {{lua_dir}}

# Check Nix formatting without modifying files
fmt-check-nix:
    @echo "Checking Nix formatting..."
    alejandra --check {{nix_files}}

# Check all code formatting without modifying
fmt-check: fmt-check-lua fmt-check-nix
    @echo "✓ All formatting checks passed"

# ============================================================================
# Code Quality - Linting
# ============================================================================

# Lint Lua files
lint-lua:
    @echo "Linting Lua files..."
    selene {{lua_dir}}

# Lint Nix files with statix (static analysis)
lint-nix:
    @echo "Linting Nix files with statix..."
    statix check

# Find dead Nix code
lint-deadnix:
    @echo "Checking for dead Nix code..."
    deadnix

# Lint all code (Lua and Nix)
lint: lint-lua lint-nix lint-deadnix
    @echo "✓ All linting checks passed"

# ============================================================================
# Validation
# ============================================================================

# Run Neovim health check from command line
health: build
    @echo "Running health check..."
    @{{result_bin}} --headless -c "checkhealth ergotu" -c "quit" || true

# Run health check interactively
health-interactive: build
    {{result_bin}} -c "checkhealth ergotu"

# Verify configuration loads successfully
verify: build
    @echo "Verifying configuration loads..."
    @export HOME="$$(mktemp -d)" && \
    export NVIM_SILENT=1 && \
    {{result_bin}} --headless '+lua require("ergotu.health").loaded_exit()' '+q' && \
    echo "✓ Configuration loaded successfully" || \
    (echo "✗ Configuration failed to load" && exit 1)

# ============================================================================
# Development
# ============================================================================

# Enter development shell
dev:
    nix develop

# Show flake information
info:
    nix flake show

# Update flake inputs
update:
    @echo "Updating flake inputs..."
    nix flake update

# Update a specific flake input
update-input INPUT:
    @echo "Updating {{INPUT}}..."
    nix flake update {{INPUT}}

# Check flake for issues
check:
    @echo "Checking flake..."
    nix flake check

# Show flake metadata
metadata:
    nix flake metadata

# ============================================================================
# Meta Tasks - Combined Workflows
# ============================================================================

# Quick check: format check + lint (no modifications)
quick-check: fmt-check lint
    @echo "✓ Quick check passed"

# Full check: format, lint, build, verify, health
full-check: fmt lint build verify health
    @echo "✓ Full check passed"

# Pre-commit: format, lint, and verify (but don't run health)
pre-commit: fmt lint verify
    @echo "✓ Pre-commit checks passed"

# CI workflow: format check, lint, build with trace, verify
ci: fmt-check lint build-trace verify
    @echo "✓ CI checks passed"

# Development cycle: format, lint, build dev, and run
dev-cycle: fmt lint build-dev run-dev

# Debug workflow: format, lint, build, run with debug
debug-workflow: fmt lint build run-debug

# Profile workflow: format, lint, build, run with profiling
profile-workflow: fmt lint build run-prof

# ============================================================================
# Utility Tasks
# ============================================================================

# Show this help message
help:
    @just --list

# Show detailed justfile documentation
docs:
    @just --list --unsorted
    @echo ""
    @echo "Common workflows:"
    @echo "  just             - Default: format, lint, build, health check"
    @echo "  just dev-cycle   - Quick dev: format, lint, build dev, run"
    @echo "  just pre-commit  - Before committing: format, lint, verify"
    @echo "  just ci          - CI checks: format check, lint, build, verify"
    @echo ""
    @echo "Quick tasks:"
    @echo "  just fmt         - Format all code"
    @echo "  just lint        - Lint all code"
    @echo "  just build       - Build release version"
    @echo "  just run         - Run built Neovim"
    @echo ""
    @echo "Debug tasks:"
    @echo "  just run-debug   - Run with DEBUG_ERGOTU=1"
    @echo "  just run-prof    - Run with PROF=1"
    @echo "  just health      - Run :checkhealth ergotu"
