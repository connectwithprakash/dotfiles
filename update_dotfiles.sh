#!/bin/bash

# Define root directory where update_dotfiles.sh script resides
ROOT_DIR=$(dirname "$(realpath "$0")")

# Ensure root directory exists
if [ ! -d "$ROOT_DIR" ]; then
  echo "Root directory '$ROOT_DIR' not found."
  exit 1
fi

# Function to prompt user with yes/no question
prompt_yes_no() {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
      [Yy]* ) return 0;;  # User answered yes
      [Nn]* ) return 1;;  # User answered no
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# List dot files in the project structure
dotfiles=(
  ".aliases"
  ".bash_profile"
  ".gitconfig"
  ".gitignore"
  ".vimrc"
)

# Additional dot files inside zsh directory with their relative paths
zsh_dotfiles=(
  "zsh/.p10k.zsh"
  "zsh/.zsh_history"
  "zsh/.zshrc"
)

# Function to show differences in files
show_diff() {
  local file=$1
  local repo_path="$ROOT_DIR/$file"
  local home_file=".${file#*.}"  # Remove "zsh/" prefix from file for home path
  local home_path="$HOME/$home_file"

  echo "Differences in dotfile: $home_file"  # Use modified file name for home path
  echo "---------------------------------"
  echo "File path in dotfiles repo: $repo_path"
  echo "File path in home directory: $home_path"
  echo ""

  diff -u "$home_path" "$repo_path"
  echo ""
}

# Function to sync files from repo to home directory
sync_to_home() {
  local file=$1
  local repo_path="$ROOT_DIR/$file"
  local home_file=".${file#*.}"  # Remove "zsh/" prefix from file for home path
  local home_path="$HOME/$home_file"

  mkdir -p "$(dirname "$home_path")"
  cp "$repo_path" "$home_path"
  echo "Synced $home_file from dotfiles repository to home directory."
}

# Function to sync files from home directory to repo
sync_to_repo() {
  local file=$1
  local repo_path="$ROOT_DIR/$file"
  local home_file=".${file#*.}"  # Remove "zsh/" prefix from file for home path
  local home_path="$HOME/$home_file"

  mkdir -p "$(dirname "$repo_path")"
  cp "$home_path" "$repo_path"
  echo "Synced $home_file from home directory to dotfiles repository."
}

# Prompt user if they want to see the changes before syncing
if prompt_yes_no "Do you want to see the changes before syncing dotfiles?"; then
  # Show differences for dotfiles in root directory
  for file in "${dotfiles[@]}"; do
    show_diff "$file"
  done

  # Show differences for dotfiles in zsh directory
  for file in "${zsh_dotfiles[@]}"; do
    show_diff "$file"
  done

  # Prompt user to confirm sync
  if prompt_yes_no "Do you want to sync dotfiles?"; then
    # Sync dotfiles in both directions
    for file in "${dotfiles[@]}"; do
      sync_to_home "$file"
    done

    for file in "${zsh_dotfiles[@]}"; do
      sync_to_home "$file"
    done

    echo "Dotfiles synced successfully."
  else
    echo "Sync aborted."
  fi
else
  # Sync dotfiles without showing differences
  for file in "${dotfiles[@]}"; do
    sync_to_home "$file"
  done

  for file in "${zsh_dotfiles[@]}"; do
    sync_to_home "$file"
  done

  echo "Dotfiles synced successfully."
fi
