#!/usr/bin/env bash

# Change directory to the location of the script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Update from the remote repository
git pull origin main

# Function to sync dotfiles only if there are changes
function syncDotfiles() {
  echo "Syncing dotfiles..."
  rsync_output=$(rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "LICENSE-MIT.txt" \
    -avh --no-perms . ~)

  if [ -n "$rsync_output" ]; then
    echo "Dotfiles were updated. Sourcing .bash_profile..."
    source ~/.bash_profile
  else
    echo "No changes in dotfiles. Skipping sourcing of .bash_profile."
  fi
}

# Function to install dependencies only if not already installed
function installDependencies() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run install_dependencies.sh script if it exists and is executable
  if [ -f "$DOTFILES_DIR/scripts/install_dependencies.sh" ] && [ -x "$DOTFILES_DIR/scripts/install_dependencies.sh" ]; then
    echo "Checking dependencies..."
    "$DOTFILES_DIR/scripts/install_dependencies.sh"
  else
    echo "scripts/install_dependencies.sh not found or not executable. Skipping dependency installation."
  fi
}

# Function to install zsh configurations only if necessary
function installZsh() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run zsh install script if it exists and is executable
  if [ -f "$DOTFILES_DIR/zsh/install.sh" ] && [ -x "$DOTFILES_DIR/zsh/install.sh" ]; then
    echo "Installing Zsh configurations..."
    "$DOTFILES_DIR/zsh/install.sh"
  else
    echo "zsh/install.sh not found or not executable. Skipping Zsh setup."
  fi
}

# Function to install VS Code configurations only if necessary
function installVSCode() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run vscode install script if it exists and is executable
  if [ -f "$DOTFILES_DIR/vscode/install.sh" ] && [ -x "$DOTFILES_DIR/vscode/install.sh" ]; then
    echo "Installing VS Code configurations..."
    "$DOTFILES_DIR/vscode/install.sh"
  else
    echo "vscode/install.sh not found or not executable. Skipping VS Code setup."
  fi
}

# Main execution logic
if [ "$1" = "--force" -o "$1" = "-f" ]; then
  installDependencies
  syncDotfiles
  installZsh
  installVSCode
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    installDependencies
    syncDotfiles
    installZsh
    installVSCode
  fi
fi

# Unset functions to clean up the environment
unset syncDotfiles
unset installDependencies
unset installZsh
unset installVSCode
