# Dotfiles

Personal development environment configurations for macOS (with partial Linux support).

## What's Included

| Component | Description |
|-----------|-------------|
| **Zsh** | Oh My Zsh + Starship prompt + autosuggestions, syntax highlighting, history search |
| **Bash** | `.bash_profile` with completions, aliases, functions, git-aware prompt |
| **Neovim** | lazy.nvim, native LSP (mason), treesitter, telescope, nvim-cmp |
| **VS Code** | Automated install (ARM64 + Intel), font setup, PATH configuration |
| **Git** | Aliases, sensible defaults, global ignore |
| **tmux** | Vim-style keybindings, mouse support, sane defaults |
| **Claude Code** | Global settings and skills sync |
| **macOS** | System preferences (Finder, Dock, keyboard, screenshots, etc.) |
| **System** | Homebrew, jq, tree, btop, tmux, ripgrep, fd, fzf, gum, starship, zoxide |
| **Python** | pipx-managed black, flake8, poetry |

## Quick Start

**One-liner install:**

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/connectwithprakash/dotfiles/main/install.sh)"
```

**Or clone and run manually:**

```bash
git clone https://github.com/connectwithprakash/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh          # Interactive setup
./bootstrap.sh --force  # Install everything without prompts
```

## Usage

```bash
./dotfiles                  # Interactive TUI menu
./dotfiles sync             # Sync dotfiles between ~ and repo
./dotfiles install          # Install/update components
./dotfiles update           # Update all installed tools and plugins
./dotfiles status           # Show installed components
./dotfiles health           # Run system health check
./dotfiles help             # Show help
```

### Make targets

```bash
make help               # Show all available targets
make install            # Full interactive installation
make install-force      # Install everything without prompts
make install-zsh        # Install just Zsh
make install-neovim     # Install just Neovim
make lint               # Run shellcheck on all scripts
make test               # Run all validation
make macos              # Apply macOS system preferences
```

## Syncing Dotfiles

```bash
./update_dotfiles.sh
```

Choose direction:
1. **Home -> Repository** -- After making local changes you want to commit
2. **Repository -> Home** -- After pulling updates from git

Files are backed up to `~/.dotfiles-backup/` before being overwritten.

## Directory Structure

```
.
├── .aliases              # Shell aliases (platform-guarded)
├── .bash_profile         # Bash configuration (loads modular dotfiles)
├── .bash_prompt          # Git-aware bash prompt
├── .editorconfig         # Editor settings
├── .exports              # Environment variable exports
├── .functions            # Useful shell functions
├── .gitconfig            # Git configuration
├── .gitignore            # Global git ignore
├── .inputrc              # Readline configuration
├── .path                 # Custom PATH entries (machine-specific)
├── .tmux.conf            # tmux configuration
├── .vimrc                # Vim configuration
├── bootstrap.sh          # Main setup orchestrator
├── dotfiles              # CLI entry point
├── install.sh            # Universal one-liner installer
├── Makefile              # Make targets for common operations
├── update_dotfiles.sh    # Bidirectional sync tool
├── neovim/
│   ├── install.sh        # Neovim + lazy.nvim + LSP setup
│   └── init.lua          # Neovim configuration (Lua)
├── scripts/
│   ├── lib.sh            # Shared utility functions
│   ├── install_system_dependencies.sh
│   ├── install_pipx_dependencies.sh
│   └── macos.sh          # macOS system preferences
├── vscode/
│   ├── install.sh        # VS Code setup (auto-detects architecture)
│   └── fix_vscode_fonts.sh
├── zsh/
│   ├── install.sh        # Zsh + Oh My Zsh + Starship + plugins
│   ├── uninstall.sh      # Clean removal
│   ├── backup_zsh_dotfiles.sh
│   ├── .zshrc
│   └── starship.toml     # Starship prompt config
├── .claude/
│   ├── install.sh        # Claude Code config sync
│   ├── settings.json
│   └── skills/
└── .github/
    └── workflows/
        └── lint.yml      # Shellcheck CI
```

## Customization

The `.bash_profile` loads files in this order if they exist:

| File | Purpose |
|------|---------|
| `~/.path` | Custom PATH additions (machine-specific, not committed) |
| `~/.bash_prompt` | Bash prompt (Zsh uses Starship instead) |
| `~/.exports` | Environment variables |
| `~/.aliases` | Shell aliases |
| `~/.functions` | Shell functions |
| `~/.extra` | Private settings (not committed) |

Edit files in `~`, test them, then run `./update_dotfiles.sh` to sync back to the repo.

## License

[MIT](LICENSE)

## Credits

Based on [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles).
