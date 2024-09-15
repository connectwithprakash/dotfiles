#!/usr/bin/env bash

# Change directory to the location of the script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Update from the remote repository
git pull origin main

# Function to sync dotfiles only if there are changes
function syncDotfiles() {
  echo "🔄 Syncing your dotfiles to ensure everything is up-to-date..."
  rsync_output=$(rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "LICENSE-MIT.txt" \
    -avh --no-perms . ~)

  if [ -n "$rsync_output" ]; then
    echo "✨ Dotfiles have been updated. Sourcing .bash_profile to apply changes..."
    source ~/.bash_profile
  else
    echo "✅ No changes detected in dotfiles. Skipping sourcing of .bash_profile."
  fi
}

# Function to install system dependencies only if not already installed
function installSystemDependencies() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run install_system_dependencies.sh script if it exists and is executable
  if [ -f "$DOTFILES_DIR/scripts/install_system_dependencies.sh" ] && [ -x "$DOTFILES_DIR/scripts/install_system_dependencies.sh" ]; then
    echo "🔍 Checking and installing necessary system dependencies..."
    "$DOTFILES_DIR/scripts/install_system_dependencies.sh"
  else
    echo "⚠️ System dependencies script not found or not executable. Skipping system dependency installation."
  fi
}

# Function to install pipx-managed dependencies only if not already installed
function installPipxDependencies() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run install_pipx_dependencies.sh script if it exists and is executable
  if [ -f "$DOTFILES_DIR/scripts/install_pipx_dependencies.sh" ] && [ -x "$DOTFILES_DIR/scripts/install_pipx_dependencies.sh" ]; then
    echo "📦 Checking and installing pipx-managed dependencies..."
    "$DOTFILES_DIR/scripts/install_pipx_dependencies.sh"
  else
    echo "⚠️ Pipx dependencies script not found or not executable. Skipping pipx dependency installation."
  fi
}

# Function to install Zsh configurations only if necessary
function installZsh() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run zsh install script if it exists and is executable
  if [ -f "$DOTFILES_DIR/zsh/install.sh" ] && [ -x "$DOTFILES_DIR/zsh/install.sh" ]; then
    echo "🔧 Installing Zsh configurations..."
    "$DOTFILES_DIR/zsh/install.sh"
  else
    echo "⚠️ zsh/install.sh not found or not executable. Skipping Zsh setup."
  fi
}

# Function to install VS Code configurations only if necessary
function installVSCode() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run vscode install script if it exists and is executable
  if [ -f "$DOTFILES_DIR/vscode/install.sh" ] && [ -x "$DOTFILES_DIR/vscode/install.sh" ]; then
    echo "🖥️ Installing VS Code configurations..."
    "$DOTFILES_DIR/vscode/install.sh"
  else
    echo "⚠️ vscode/install.sh not found or not executable. Skipping VS Code setup."
  fi
}

# Function to install Neovim and its configurations
function installNeovim() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run neovim install script if it exists and is executable
  if [ -f "$DOTFILES_DIR/neovim/install.sh" ] && [ -x "$DOTFILES_DIR/neovim/install.sh" ]; then
    echo "📝 Installing Neovim and its configurations..."
    "$DOTFILES_DIR/neovim/install.sh"
  else
    echo "⚠️ neovim/install.sh not found or not executable. Skipping Neovim setup."
  fi
}

# Main execution logic
if [ "$1" = "--force" -o "$1" = "-f" ]; then
  installSystemDependencies
  installPipxDependencies
  syncDotfiles
  installZsh
  installVSCode
  installNeovim
else
  read -p "🔄 Do you want to install system dependencies? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    installSystemDependencies
  fi

  read -p "📦 Do you want to install pipx dependencies? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    installPipxDependencies
  fi

  read -p "🔄 Do you want to sync your dotfiles? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    syncDotfiles
  fi

  read -p "🔧 Do you want to install Zsh configurations? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    installZsh
  fi

  read -p "🖥️ Do you want to install VS Code configurations? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    installVSCode
  fi

  read -p "📝 Do you want to install Neovim and its configurations? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    installNeovim
  fi
fi

# Unset functions to clean up the environment
unset syncDotfiles
unset installSystemDependencies
unset installPipxDependencies
unset installZsh
unset installVSCode
unset installNeovim

echo "🎉 All tasks completed! Your environment is now set up and ready to use."