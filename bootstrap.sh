#!/usr/bin/env bash

# Change directory to the location of the script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Update from remote repository
git pull origin main

# Function to sync dotfiles
function syncDotfiles() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "LICENSE-MIT.txt" \
    -avh --no-perms . ~
  source ~/.bash_profile
}

# Function to install dependencies
function installDependencies() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run install_dependencies.sh script if it exists
  if [ -f "$DOTFILES_DIR/scripts/install_dependencies.sh" ]; then
    echo "Running install_dependencies.sh..."
    "$DOTFILES_DIR/scripts/install_dependencies.sh"
  else
    echo "scripts/install_dependencies.sh not found. Skipping dependency installation."
  fi
}

# Function to install zsh configurations
function installZsh() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run zsh install script if it exists
  if [ -f "$DOTFILES_DIR/zsh/install.sh" ]; then
    echo "Running zsh install script..."
    "$DOTFILES_DIR/zsh/install.sh"
  else
    echo "zsh/install.sh not found. Skipping Zsh setup."
  fi
}

# Function to install vscode configurations
function installVSCode() {
  # Dotfiles directory
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # Run vscode install script if it exists
  if [ -f "$DOTFILES_DIR/vscode/install.sh" ]; then
    echo "Running VS Code install script..."
    "$DOTFILES_DIR/vscode/install.sh"
  else
    echo "vscode/install.sh not found. Skipping VS Code setup."
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

unset syncDotfiles
unset installDependencies
unset installZsh
unset installVSCode
