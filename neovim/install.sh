#!/usr/bin/env bash

set -e

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not installed
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
  else
    echo "Homebrew is already installed."
  fi
}

# Install Neovim
install_neovim() {
  if ! command_exists nvim; then
    echo "Installing Neovim..."
    brew install neovim
  else
    echo "Neovim is already installed. Updating..."
    brew upgrade neovim || true
  fi
}

# Install ripgrep (required by Telescope live_grep)
install_ripgrep() {
  if ! command_exists rg; then
    echo "Installing ripgrep..."
    brew install ripgrep
  else
    echo "ripgrep is already installed."
  fi
}

# Install fd (faster find, used by Telescope)
install_fd() {
  if ! command_exists fd; then
    echo "Installing fd..."
    brew install fd
  else
    echo "fd is already installed."
  fi
}

# Copy init.lua to the Neovim configuration directory
setup_config() {
  local config_dir="$HOME/.config/nvim"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  mkdir -p "$config_dir"

  # Use init.lua (modern Lua config)
  if [ -f "$script_dir/init.lua" ]; then
    echo "Copying init.lua to Neovim configuration directory..."
    cp "$script_dir/init.lua" "$config_dir/init.lua"
    # Remove legacy init.vim if present
    [ -f "$config_dir/init.vim" ] && rm -f "$config_dir/init.vim"
  else
    echo "Warning: init.lua not found in the repository."
  fi
}

# Install plugins via lazy.nvim (self-bootstrapping, runs on first launch)
install_plugins() {
  echo "Installing Neovim plugins (lazy.nvim bootstraps automatically)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  echo "Plugins installed."
}

# Install Mason LSP servers
install_lsp_servers() {
  echo "Installing LSP servers via Mason..."
  nvim --headless "+MasonInstall lua-language-server pyright typescript-language-server bash-language-server json-lsp" +qa 2>/dev/null || true
  echo "LSP servers installed."
}

# Set VIMRUNTIME environment variable
set_vimruntime() {
  if ! command_exists nvim; then
    echo "Warning: Neovim not found. Cannot set VIMRUNTIME."
    return
  fi

  local brew_prefix
  brew_prefix="$(brew --prefix 2>/dev/null || echo "")"
  local vimruntime_path="$brew_prefix/share/nvim/runtime"

  if [ -z "$brew_prefix" ] || [ ! -d "$vimruntime_path" ]; then
    local vim_version
    vim_version=$(nvim --version | head -n 1 | awk '{print $2}' | sed 's/^v//')
    vimruntime_path="$brew_prefix/Cellar/neovim/${vim_version}/share/nvim/runtime"
  fi

  if [ -d "$vimruntime_path" ]; then
    export VIMRUNTIME="$vimruntime_path"
    echo "VIMRUNTIME set to $vimruntime_path"
  else
    echo "Warning: VIMRUNTIME path does not exist. Check your Neovim installation."
  fi
}

# Check health of the setup
check_health() {
  echo "Checking health of the setup..."

  for tool in brew nvim rg fd; do
    if command_exists "$tool"; then
      echo "  [ok] $tool is installed."
    else
      echo "  [missing] $tool is not installed."
    fi
  done

  if [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
    echo "  [ok] lazy.nvim is installed."
  else
    echo "  [missing] lazy.nvim is not installed."
  fi

  if [ -n "$VIMRUNTIME" ] && [ -d "$VIMRUNTIME" ]; then
    echo "  [ok] VIMRUNTIME is set correctly."
  else
    echo "  [missing] VIMRUNTIME is not set correctly."
  fi

  echo "Health check complete!"
}

# Suppress Homebrew noise
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Main
echo "Starting Neovim setup..."
install_brew
install_neovim
install_ripgrep
install_fd
setup_config
set_vimruntime
install_plugins
install_lsp_servers
check_health
echo "Neovim setup complete!"
