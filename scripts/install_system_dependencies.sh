#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if missing
install_brew() {
  if ! command_exists brew; then
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "Homebrew installation complete!"
  fi
}

# macOS: use Brewfile (declarative, single command)
install_with_brewfile() {
  install_brew
  echo "Installing dependencies from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
  echo "All Homebrew dependencies installed!"
}

# Linux: install individually via apt
install_with_apt() {
  if ! command_exists apt-get; then
    echo "APT not available. Please install dependencies manually."
    return 1
  fi

  # Map Homebrew package names to apt package names where they differ
  declare -A APT_NAMES=(
    [neovim]="neovim"
    [ripgrep]="ripgrep"
    [fd]="fd-find"
    [fzf]="fzf"
    [tmux]="tmux"
    [jq]="jq"
    [tree]="tree"
    [btop]="btop"
  )

  sudo apt-get update -qq

  for pkg in jq tree btop tmux neovim ripgrep fd fzf; do
    local apt_name="${APT_NAMES[$pkg]:-$pkg}"
    local binary="$pkg"
    case "$pkg" in
      neovim) binary="nvim" ;;
      ripgrep) binary="rg" ;;
    esac

    if ! command_exists "$binary"; then
      echo "Installing $pkg..."
      sudo apt-get install -y "$apt_name"
    else
      echo "$pkg is already installed. Skipping."
    fi
  done

  # Tools that need special install on Linux
  if ! command_exists starship; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  if ! command_exists zoxide; then
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi

  if ! command_exists gum; then
    echo "Installing gum..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt-get update -qq && sudo apt-get install -y gum
  fi

  if ! command_exists pipx; then
    echo "Installing pipx..."
    sudo apt-get install -y pipx
    pipx ensurepath
  fi
}

# Main
case "$(uname -s)" in
  Darwin)
    install_with_brewfile
    ;;
  Linux)
    install_with_apt
    ;;
  *)
    echo "Unsupported operating system. Please install dependencies manually."
    exit 1
    ;;
esac

echo "All system dependencies installed!"
