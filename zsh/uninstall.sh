#!/usr/bin/env bash

set -e

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to uninstall Oh My Zsh
uninstall_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Uninstalling Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    echo "Oh My Zsh has been uninstalled."
  else
    echo "Oh My Zsh is not installed."
  fi

  [ -f "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc" && echo "Removed .zshrc"
  [ -f "$HOME/.p10k.zsh" ] && rm -f "$HOME/.p10k.zsh" && echo "Removed legacy .p10k.zsh"
  [ -f "$HOME/.config/starship.toml" ] && rm -f "$HOME/.config/starship.toml" && echo "Removed starship.toml"
}

# Function to uninstall Zsh
uninstall_zsh() {
  if command_exists zsh; then
    echo "Uninstalling Zsh..."
    if command_exists brew; then
      brew uninstall zsh || true
    elif command_exists apt-get; then
      sudo apt-get remove --purge -y zsh
    else
      echo "Package manager not supported. Please uninstall Zsh manually."
      return 1
    fi
    echo "Zsh has been uninstalled."
  else
    echo "Zsh is not installed."
  fi
}

# Function to change default shell back to Bash
change_default_shell() {
  if [ "$SHELL" != "/bin/bash" ]; then
    echo "Changing the default shell back to Bash..."
    chsh -s /bin/bash "$USER"
  else
    echo "Default shell is already Bash."
  fi
}

# Function to remove Zsh-related files (NOT ~/.cache which belongs to many apps)
remove_zsh_files() {
  echo "Removing Zsh-related files..."
  rm -f "$HOME/.zsh_history"
  rm -f "$HOME/.zshenv"
  rm -f "$HOME/.zlogin"
  rm -f "$HOME/.zlogout"
  rm -rf "$HOME/.zsh"
  rm -rf "$HOME/.zshrc.d"
  # Only remove zsh-specific cache, not the entire ~/.cache
  rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-"*
  rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
}

# Remove 'exec zsh' from .bashrc if present
cleanup_bashrc() {
  if [ -f "$HOME/.bashrc" ] && grep -q "exec zsh" "$HOME/.bashrc"; then
    # Portable sed -i: macOS requires '' arg, GNU doesn't
    if [[ "$(uname -s)" == "Darwin" ]]; then
      sed -i '' '/exec zsh/d' "$HOME/.bashrc"
    else
      sed -i '/exec zsh/d' "$HOME/.bashrc"
    fi
    echo "Removed 'exec zsh' from .bashrc"
  fi
}

# Main
echo "This will uninstall Zsh, Oh My Zsh, and all related configurations."
read -p "Are you sure? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

uninstall_oh_my_zsh
change_default_shell
remove_zsh_files
cleanup_bashrc
uninstall_zsh

echo "Uninstallation complete. Please restart your terminal."
