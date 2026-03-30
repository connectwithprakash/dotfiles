# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Overview

Personal dotfiles repository for managing development environment configurations across macOS systems (with partial Linux support). Handles setup and synchronization of shell configs (Bash/Zsh), editor configs (Neovim, VS Code), tmux, system dependencies, and macOS preferences.

## Core Architecture

### Bidirectional Sync Model

- **Home -> Repository**: `update_dotfiles.sh` syncs changes from `~` to repo for version control
- **Repository -> Home**: `bootstrap.sh` / `update_dotfiles.sh` deploys configs from repo to `~`
- Files are backed up to `~/.dotfiles-backup/` before overwriting

### Shared Library

`scripts/lib.sh` provides common functions used across all scripts:
- `command_exists`, `prompt_yes_no`, `backup_file`
- Color output helpers (`print_success`, `print_error`, `print_info`, `print_warning`)
- Portable Homebrew detection (`get_brew_prefix`, `ensure_brew_in_path`)

### Managed Dotfiles

**Root-level dotfiles** (synced via rsync/cp):
- `.bash_profile` - Bash config, loads modular dotfiles (`.path`, `.bash_prompt`, `.exports`, `.aliases`, `.functions`, `.extra`)
- `.bash_prompt` - Git-aware bash prompt with colors (Zsh uses Starship instead)
- `.aliases` - Shell aliases for navigation, system commands, Python (platform-guarded for macOS/Linux)
- `.exports` - Environment variables (EDITOR, LANG, HISTSIZE, etc.)
- `.functions` - Utility shell functions (mkd, targz, fs, server, tre, etc.)
- `.path` - Custom PATH entries (machine-specific)
- `.inputrc` - Readline configuration (case-insensitive completion, history search)
- `.tmux.conf` - tmux configuration (Ctrl+a prefix, vim keys, mouse support)
- `.gitconfig`, `.gitignore`, `.vimrc`, `.editorconfig`

**Zsh dotfiles** (in `zsh/` directory):
- `.zshrc` - Main Zsh config (Oh My Zsh, plugins, Starship prompt)
- `starship.toml` - Starship prompt configuration (deployed to `~/.config/starship.toml`)

## Essential Commands

```bash
# Full setup
./bootstrap.sh              # Interactive
./bootstrap.sh --force      # Unattended

# CLI tool
./dotfiles sync             # Sync dotfiles
./dotfiles install          # Install components
./dotfiles update           # Update all tools and plugins
./dotfiles status           # Show status
./dotfiles health           # Health check

# Make targets
make install                # Interactive install
make install-force          # Unattended install
make lint                   # Shellcheck all scripts
make test                   # Full validation
make macos                  # Apply macOS preferences

# Component-specific
./scripts/install_system_dependencies.sh
./scripts/install_python_tools.sh
./zsh/install.sh
./neovim/install.sh
./vscode/install.sh
./.claude/install.sh
./scripts/macos.sh
```

## Key Design Patterns

### Idempotent Scripts
All install scripts check for existing installations before proceeding. Safe to run multiple times.

### Portable Homebrew Detection
Scripts detect both ARM64 (`/opt/homebrew`) and Intel (`/usr/local`) Homebrew paths. No hardcoded architecture assumptions.

### Resilient VIMRUNTIME
Uses `brew --prefix` for a version-independent path that survives Neovim upgrades, with fallback to version-specific Cellar path.

### Configuration Layering (.bash_profile)
```bash
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
```

`~/.extra` and `~/.path` are for machine-specific settings not committed to the repo.

## System Dependencies

**Homebrew packages** (declared in `Brewfile`, installed via `brew bundle`): gh, jq, tree, btop, tmux, neovim, ripgrep, fd, gum, fzf, starship, zoxide, pyenv, uv, ruff, stats (macOS cask)

**Python toolchain** (installed via `scripts/install_python_tools.sh`):
- `pyenv` - Python version management
- `uv` - Fast package/project manager (replaces pip, venv, pipx, poetry for most workflows)
- `ruff` - Fast linter + formatter (replaces black, flake8, isort)
- `poetry`, `ipython` - Installed as global tools via `uv tool install`

**Zsh plugins**: zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting, zsh-history-substring-search

## Tool Stack

### Shell: Zsh + Oh My Zsh + Starship
- **Oh My Zsh** for plugin management and framework
- **Starship** for prompt (replaces archived Powerlevel10k, Rust-based, cross-shell)
- **fzf** for fuzzy finding (integrated via `fzf --zsh`)
- **zoxide** for smarter `cd` navigation

### Editor: Neovim + lazy.nvim + Native LSP
- **lazy.nvim** for plugin management (replaces Vim-Plug, self-bootstrapping, lazy-loading)
- **init.lua** configuration (replaces legacy init.vim Vimscript)
- **nvim-lspconfig** + **mason.nvim** for language server management (replaces Node-dependent CoC)
- **nvim-cmp** for autocompletion with LSP integration
- **nvim-treesitter** for syntax highlighting and indentation
- **telescope.nvim** for fuzzy finding (replaces fzf.vim)
- **nvim-tree.lua** for file explorer (replaces NERDTree)
- **lualine.nvim** for statusline (replaces lightline.vim)
- **gitsigns.nvim** for git integration (replaces vim-gitgutter)

## CI/CD

GitHub Actions workflow (`.github/workflows/lint.yml`) runs shellcheck and syntax validation on all scripts.

## Modifying Configurations

1. Edit files in home directory (`~/.zshrc`, `~/.aliases`, etc.)
2. Test changes
3. Run `./update_dotfiles.sh` and select "Home to Repository"
4. Review diffs before confirming
5. Commit and push

## Claude Code Configuration

Stored in `.claude/` directory. Synced bidirectionally between repo and `~/.claude/`.
- `settings.json` - Global Claude Code settings
- `skills/` - Custom skill definitions
