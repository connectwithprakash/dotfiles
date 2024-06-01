#!/bin/bash

# Define the directory where this script is located
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the directory where you want to back up your Zsh dotfiles
DOTFILES_ZSH_DIR="$SCRIPT_DIR"

# Create the backup directory if it doesn't exist
mkdir -p $DOTFILES_ZSH_DIR

# Function to copy a file if it exists
copy_if_exists() {
  local source_file=$1
  local dest_file=$2
  if [ -f $source_file ]; then
    echo "Copying $(basename $source_file) to $DOTFILES_ZSH_DIR..."
    cp $source_file $dest_file
  else
    echo "$(basename $source_file) not found. Skipping copy."
  fi
}

# Copy .zshrc file to the backup directory
copy_if_exists $HOME/.zshrc $DOTFILES_ZSH_DIR/.zshrc

# Copy .p10k.zsh file to the backup directory
copy_if_exists $HOME/.p10k.zsh $DOTFILES_ZSH_DIR/.p10k.zsh

# Additional message to confirm backup completion
echo "Backup complete!"

