#!/bin/bash

# Define root directory where update_dotfiles.sh script resides
ROOT_DIR=$(dirname "$(realpath "$0")")

# Ensure root directory exists
if [ ! -d "$ROOT_DIR" ]; then
  echo "❌ Root directory '$ROOT_DIR' not found."
  exit 1
fi

# Function to prompt user with yes/no question
prompt_yes_no() {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
      [Yy]* ) return 0;;  # User answered yes
      [Nn]* ) return 1;;  # User answered no
      * ) echo "❗ Please answer yes or no.";;
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
  # "zsh/.zsh_history"
  "zsh/.zshrc"
)

# Function to show differences in files
show_diff() {
  local file=$1
  local repo_path="$ROOT_DIR/$file"
  local home_file=".${file#*.}"  # Remove "zsh/" prefix from file for home path
  local home_path="$HOME/$home_file"

  # Check if files are different
  if ! diff -q "$home_path" "$repo_path" >/dev/null; then
    echo "🔍 Differences in dotfile: $home_file"
    echo "---------------------------------"
    echo "📂 File path in home directory: $home_path"
    echo "📁 File path in dotfiles repo: $repo_path"
    echo ""

    diff -u "$home_path" "$repo_path"
    echo ""
  fi
}

# Function to sync files from home directory to repo
sync_to_repo() {
  local file=$1
  local repo_path="$ROOT_DIR/$file"
  local home_file=".${file#*.}"  # Remove "zsh/" prefix from file for home path
  local home_path="$HOME/$home_file"

  if [ -f "$home_path" ]; then
    if ! diff -q "$home_path" "$repo_path" >/dev/null; then
      mkdir -p "$(dirname "$repo_path")"
      cp "$home_path" "$repo_path"
      echo "✅ Synced $home_file from home directory ($home_path) to dotfiles repository ($repo_path)."
    else
      echo "⚠️ No changes detected in $home_file. Skipping sync."
    fi
  fi
}

# Function to sync files from repo to home directory
sync_to_home() {
  local file=$1
  local repo_path="$ROOT_DIR/$file"
  local home_file=".${file#*.}"  # Remove "zsh/" prefix from file for home path
  local home_path="$HOME/$home_file"

  if [ -f "$repo_path" ]; then
    if ! diff -q "$home_path" "$repo_path" >/dev/null; then
      cp "$repo_path" "$home_path"
      echo "✅ Synced $home_file from dotfiles repository ($repo_path) to home directory ($home_path)."
    else
      echo "⚠️ No changes detected in $home_file. Skipping sync."
    fi
  fi
}

# Function to prompt user for sync direction
prompt_sync_direction() {
  echo "🌟✨ Choose Your Sync Direction ✨🌟"
  echo "1) Home to Repository 🏠➡️📁"
  echo "2) Repository to Home 📁➡️🏠"
  while true; do
    read -p "Enter your choice (1/2): " direction
    case $direction in
      1 ) sync_home_to_repo; break;;
      2 ) sync_repo_to_home; break;;
      * ) echo "❗ Please choose '1' for Home to Repository or '2' for Repository to Home.";;
    esac
  done
}

# Function to prompt user to select specific dotfiles
prompt_select_dotfiles() {
  selected_dotfiles=()
  for file in "${dotfiles[@]}" "${zsh_dotfiles[@]}"; do
    if prompt_yes_no "🔄 Do you want to sync $file?"; then
      selected_dotfiles+=("$file")
    fi
  done
}

# Sync dotfiles from home directory to repository
sync_home_to_repo() {
  # Prompt user to select specific dotfiles
  prompt_select_dotfiles

  # Prompt user if they want to see the changes before syncing
  if prompt_yes_no "👀 Do you want to see the changes before syncing dotfiles?"; then
    # Show differences for selected dotfiles
    for file in "${selected_dotfiles[@]}"; do
      show_diff "$file"
    done

    # Prompt user to confirm sync
    if prompt_yes_no "🔄 Do you want to sync dotfiles?"; then
      # Sync selected dotfiles from home directory to repo
      for file in "${selected_dotfiles[@]}"; do
        sync_to_repo "$file"
      done

      echo "🎉 Dotfiles synced successfully to repository."
    else
      echo "❌ Sync aborted."
    fi
  else
    # Sync selected dotfiles without showing differences
    for file in "${selected_dotfiles[@]}"; do
      sync_to_repo "$file"
    done

    echo "🎉 Dotfiles synced successfully to repository."
  fi
}

# Sync dotfiles from repository to home directory
sync_repo_to_home() {
  # Prompt user to select specific dotfiles
  prompt_select_dotfiles

  # Prompt user if they want to see the changes before syncing
  if prompt_yes_no "👀 Do you want to see the changes before syncing dotfiles?"; then
    # Show differences for selected dotfiles
    for file in "${selected_dotfiles[@]}"; do
      show_diff "$file"
    done

    # Prompt user to confirm sync
    if prompt_yes_no "🔄 Do you want to sync dotfiles?"; then
      # Sync selected dotfiles from repo to home directory
      for file in "${selected_dotfiles[@]}"; do
        sync_to_home "$file"
      done

      echo "🎉 Dotfiles synced successfully to home directory."
    else
      echo "❌ Sync aborted."
    fi
  else
    # Sync selected dotfiles without showing differences
    for file in "${selected_dotfiles[@]}"; do
      sync_to_home "$file"
    done

    echo "🎉 Dotfiles synced successfully to home directory."
  fi
}

# Main script starts here

# Prompt user for sync direction
prompt_sync_direction