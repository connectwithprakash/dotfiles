# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing development environment configurations across macOS systems. It handles setup and synchronization of shell configurations (Bash/Zsh), editor configurations (Neovim, VS Code), and system dependencies.

## Core Architecture

### Bidirectional Sync Model

The repository uses a **bidirectional sync architecture** between the home directory (`~`) and the repository:

- **Home → Repository**: `update_dotfiles.sh` - Sync changes from `~` to the repo for version control
- **Repository → Home**: `bootstrap.sh` - Deploy configurations from repo to `~` during setup/updates

### Managed Dotfiles

**Root-level dotfiles** (synced via rsync):
- `.bash_profile` - Bash configuration, loads other dotfiles dynamically
- `.aliases` - Shell aliases for navigation, system commands, Python
- `.gitconfig`, `.gitignore`, `.vimrc`

**Zsh dotfiles** (in `zsh/` directory):
- `.zshrc` - Main Zsh configuration
- `.p10k.zsh` - Powerlevel10k theme configuration
- `.zsh_history` - Command history (not committed by default)

## Essential Commands

### Initial Setup

```bash
# Full automated setup (installs everything without prompts)
./bootstrap.sh --force

# Interactive setup (prompts for each component)
./bootstrap.sh
```

The bootstrap process installs in order:
1. System dependencies (Homebrew, jq, tree, btop, tmux, neovim, ripgrep, etc.)
2. Pipx dependencies (black, flake8, poetry)
3. Dotfiles sync (rsync to home directory)
4. Zsh setup (Oh My Zsh, Powerlevel10k, plugins)
5. VS Code installation and configuration
6. Neovim installation and plugin setup

### Syncing Dotfiles

```bash
# Sync dotfiles between home directory and repository
./update_dotfiles.sh

# Select sync direction:
# 1) Home to Repository (after making local changes)
# 2) Repository to Home (after pulling updates)

# The script will:
# - Prompt to select specific dotfiles to sync
# - Show diffs before syncing (optional)
# - Only copy files that have changed
```

### Component-Specific Setup

```bash
# Install/update system dependencies
./scripts/install_system_dependencies.sh

# Install/update Python tools via pipx
./scripts/install_pipx_dependencies.sh

# Zsh configuration management
./zsh/install.sh         # Install Zsh, Oh My Zsh, Powerlevel10k, plugins
./zsh/backup_zsh_dotfiles.sh  # Backup Zsh configs
./zsh/uninstall.sh       # Remove Zsh configurations

# Neovim setup
./neovim/install.sh      # Install Neovim, Vim-Plug, plugins, set VIMRUNTIME

# VS Code setup
./vscode/install.sh      # Install VS Code for Apple Silicon, setup PATH
./vscode/fix_vscode_fonts.sh  # Fix font rendering issues
```

## Key Design Patterns

### Idempotent Installation Scripts

All installation scripts check for existing installations before proceeding:
- Use `command_exists()` to verify if tools are already installed
- Skip installation and update instead when appropriate
- Safe to run multiple times without side effects

### Platform Detection

Scripts detect the OS and use appropriate package managers:
- **macOS**: Homebrew (`brew`)
- **Linux**: APT (`apt-get`)

### Configuration Layering (.bash_profile)

The `.bash_profile` follows a modular loading pattern:

```bash
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
```

This allows extending configurations via:
- `~/.extra` - Personal settings not committed to the repository
- `~/.path` - Custom PATH extensions
- Other dotfiles as needed

### Environment Variables

Key environment variables set during installation:

- `VIMRUNTIME` - Set dynamically based on Neovim version in `/opt/homebrew/Cellar/neovim/`
- `PATH` additions:
  - `$HOME/bin`
  - Homebrew: `/opt/homebrew/bin`
  - Pipx: `$HOME/.local/bin`
  - VS Code: `$VSCODE_APP_PATH/Contents/Resources/app/bin`

## Tool-Specific Details

### Zsh Configuration

The Zsh setup installs:
- **Oh My Zsh** framework
- **Powerlevel10k** theme
- **Plugins**:
  - `zsh-autosuggestions`
  - `zsh-completions`
  - `zsh-syntax-highlighting`

Configuration is automatically set as the default shell and added to `.bashrc` for VS Code compatibility.

### Neovim Setup

Uses **Vim-Plug** as the plugin manager. The installation:
1. Installs/updates Neovim via Homebrew
2. Installs Node.js (required for some plugins)
3. Downloads Vim-Plug to `~/.local/share/nvim/site/autoload/`
4. Copies `init.vim` to `~/.config/nvim/`
5. Sets `VIMRUNTIME` environment variable
6. Runs `nvim +PlugInstall +qall` to install plugins
7. Installs ripgrep for search functionality

### VS Code Installation

Installs VS Code for **Apple Silicon (ARM64)** specifically:
- Downloads from `https://update.code.visualstudio.com/latest/darwin-arm64/stable`
- Installs to `~/Applications/Visual Studio Code.app`
- Creates symlink `/usr/local/bin/code` for CLI access
- Adds `code` command to PATH in both `.bash_profile` and `.zshrc`

## System Dependencies

Installed via Homebrew (macOS) or APT (Linux):
- `jq` - JSON processor (required for VS Code config)
- `tree` - Directory visualization
- `btop` - Resource monitor
- `tmux` - Terminal multiplexer
- `stats` - System monitor
- `pipx` - Python application installer
- `neovim` - Text editor
- `ripgrep` - Fast grep alternative

## Python Development Setup

Pipx-managed tools (isolated Python environments):
- `black` - Code formatter
- `flake8` - Linter
- `poetry` - Dependency management

Python aliases configured in `.aliases`:
```bash
python → python3
py → python
pip → pip3
```

## Modifying Configurations

When updating dotfiles:

1. **Modify files in home directory** (`~/.zshrc`, `~/.bash_profile`, etc.)
2. **Test changes** to ensure they work
3. **Run sync script**: `./update_dotfiles.sh`
4. **Select "Home to Repository"** direction
5. **Review diffs** before confirming sync
6. **Commit and push** changes to repository

When pulling updates from repository:

1. **Pull latest changes**: `git pull origin main`
2. **Run sync script**: `./update_dotfiles.sh`
3. **Select "Repository to Home"** direction
4. **Review diffs** before confirming sync
5. **Reload shell**: `source ~/.zshrc` or `source ~/.bash_profile`

## Notes

- The repository uses rsync with exclusions (`.git/`, `.DS_Store`, `bootstrap.sh`, etc.) when syncing
- Zsh is set as the default shell in `.bashrc` via `exec zsh` for VS Code terminal compatibility
- All installation scripts include health checks to verify successful installation
- Environment variables are added to both `.bash_profile` and `.zshrc` for cross-shell compatibility
