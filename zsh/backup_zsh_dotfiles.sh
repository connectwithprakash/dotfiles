#!/usr/bin/env bash

set -e

# Define the directory where this script is located (portable, no realpath needed)
DOTFILES_ZSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to copy a file if it exists
copy_if_exists() {
  local source_file="$1"
  local dest_file="$2"
  if [ -f "$source_file" ]; then
    echo "Copying $(basename "$source_file") to $DOTFILES_ZSH_DIR..."
    cp "$source_file" "$dest_file"
  else
    echo "$(basename "$source_file") not found. Skipping copy."
  fi
}

# Copy .zshrc file to the backup directory
copy_if_exists "$HOME/.zshrc" "$DOTFILES_ZSH_DIR/.zshrc"

# Copy Starship config
copy_if_exists "$HOME/.config/starship.toml" "$DOTFILES_ZSH_DIR/starship.toml"

echo "Backup complete!"
