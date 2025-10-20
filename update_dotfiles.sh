#!/bin/bash

# Define root directory where update_dotfiles.sh script resides
ROOT_DIR=$(dirname "$(realpath "$0")")

# Ensure root directory exists
if [ ! -d "$ROOT_DIR" ]; then
  echo "❌ Root directory '$ROOT_DIR' not found."
  exit 1
fi

# Check if gum is available
HAS_GUM=false
if command -v gum &> /dev/null; then
  HAS_GUM=true
fi

# Function to prompt user with yes/no question
prompt_yes_no() {
  if [ "$HAS_GUM" = true ]; then
    gum confirm "$1"
    return $?
  else
    while true; do
      read -p "$1 (y/n): " yn
      case $yn in
        [Yy]* ) return 0;;  # User answered yes
        [Nn]* ) return 1;;  # User answered no
        * ) echo "❗ Please answer yes or no.";;
      esac
    done
  fi
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
  if ! diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
    if [ "$HAS_GUM" = true ]; then
      gum style --border rounded --border-foreground 212 --padding "0 1" "🔍 Differences in: $home_file"
      echo ""
      echo "📂 Home: $home_path"
      echo "📁 Repo: $repo_path"
      echo ""
    else
      echo "🔍 Differences in dotfile: $home_file"
      echo "---------------------------------"
      echo "📂 File path in home directory: $home_path"
      echo "📁 File path in dotfiles repo: $repo_path"
      echo ""
    fi

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
    if ! diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
      mkdir -p "$(dirname "$repo_path")"
      if [ "$HAS_GUM" = true ]; then
        gum spin --spinner dot --title "Syncing $home_file..." -- sleep 0.2
      fi
      cp "$home_path" "$repo_path"
      echo "✅ Synced $home_file to repository"
    else
      echo "⚠️  No changes in $home_file (skipped)"
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
    if ! diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
      if [ "$HAS_GUM" = true ]; then
        gum spin --spinner dot --title "Syncing $home_file..." -- sleep 0.2
      fi
      cp "$repo_path" "$home_path"
      echo "✅ Synced $home_file to home directory"
    else
      echo "⚠️  No changes in $home_file (skipped)"
    fi
  fi
}

# Function to prompt user for sync direction
prompt_sync_direction() {
  if [ "$HAS_GUM" = true ]; then
    gum style \
      --border double \
      --border-foreground 212 \
      --padding "1 2" \
      --margin "1 0" \
      "🔄 Dotfiles Sync Manager" \
      "" \
      "Choose your sync direction:"

    DIRECTION=$(gum choose \
      "🏠 ➡️  📁  Home → Repository" \
      "📁 ➡️  🏠  Repository → Home")

    case "$DIRECTION" in
      *"Home → Repository"*) sync_home_to_repo;;
      *"Repository → Home"*) sync_repo_to_home;;
    esac
  else
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
  fi
}

# Function to prompt user to select specific dotfiles
prompt_select_dotfiles() {
  selected_dotfiles=()

  if [ "$HAS_GUM" = true ]; then
    echo ""
    gum style --foreground 212 "Select dotfiles to sync:"

    # Combine all dotfiles for selection
    all_files=("${dotfiles[@]}" "${zsh_dotfiles[@]}")

    # Use gum choose with multi-select (compatible with Bash 3.2+)
    while IFS= read -r file; do
      selected_dotfiles+=("$file")
    done < <(printf '%s\n' "${all_files[@]}" | gum choose --no-limit --height 15)

    if [ ${#selected_dotfiles[@]} -eq 0 ]; then
      echo "❌ No dotfiles selected. Aborting."
      exit 0
    fi
  else
    for file in "${dotfiles[@]}" "${zsh_dotfiles[@]}"; do
      if prompt_yes_no "🔄 Do you want to sync $file?"; then
        selected_dotfiles+=("$file")
      fi
    done

    if [ ${#selected_dotfiles[@]} -eq 0 ]; then
      echo "❌ No dotfiles selected. Aborting."
      exit 0
    fi
  fi
}

# Sync dotfiles from home directory to repository
sync_home_to_repo() {
  # Prompt user to select specific dotfiles
  prompt_select_dotfiles

  echo ""
  if [ "$HAS_GUM" = true ]; then
    gum style --foreground 212 "📋 Selected ${#selected_dotfiles[@]} file(s) for sync"
  else
    echo "📋 Selected ${#selected_dotfiles[@]} file(s) for sync"
  fi
  echo ""

  # Prompt user if they want to see the changes before syncing
  if prompt_yes_no "👀 Preview changes before syncing?"; then
    # Show differences for selected dotfiles
    for file in "${selected_dotfiles[@]}"; do
      show_diff "$file"
    done

    # Prompt user to confirm sync
    if prompt_yes_no "🔄 Proceed with sync?"; then
      echo ""
      # Sync selected dotfiles from home directory to repo
      for file in "${selected_dotfiles[@]}"; do
        sync_to_repo "$file"
      done

      echo ""
      if [ "$HAS_GUM" = true ]; then
        gum style --foreground 212 --bold "🎉 Sync complete! Files updated in repository."
      else
        echo "🎉 Dotfiles synced successfully to repository."
      fi
    else
      echo "❌ Sync aborted."
    fi
  else
    echo ""
    # Sync selected dotfiles without showing differences
    for file in "${selected_dotfiles[@]}"; do
      sync_to_repo "$file"
    done

    echo ""
    if [ "$HAS_GUM" = true ]; then
      gum style --foreground 212 --bold "🎉 Sync complete! Files updated in repository."
    else
      echo "🎉 Dotfiles synced successfully to repository."
    fi
  fi
}

# Sync dotfiles from repository to home directory
sync_repo_to_home() {
  # Prompt user to select specific dotfiles
  prompt_select_dotfiles

  echo ""
  if [ "$HAS_GUM" = true ]; then
    gum style --foreground 212 "📋 Selected ${#selected_dotfiles[@]} file(s) for sync"
  else
    echo "📋 Selected ${#selected_dotfiles[@]} file(s) for sync"
  fi
  echo ""

  # Prompt user if they want to see the changes before syncing
  if prompt_yes_no "👀 Preview changes before syncing?"; then
    # Show differences for selected dotfiles
    for file in "${selected_dotfiles[@]}"; do
      show_diff "$file"
    done

    # Prompt user to confirm sync
    if prompt_yes_no "🔄 Proceed with sync?"; then
      echo ""
      # Sync selected dotfiles from repo to home directory
      for file in "${selected_dotfiles[@]}"; do
        sync_to_home "$file"
      done

      echo ""
      if [ "$HAS_GUM" = true ]; then
        gum style --foreground 212 --bold "🎉 Sync complete! Files updated in home directory."
      else
        echo "🎉 Dotfiles synced successfully to home directory."
      fi
    else
      echo "❌ Sync aborted."
    fi
  else
    echo ""
    # Sync selected dotfiles without showing differences
    for file in "${selected_dotfiles[@]}"; do
      sync_to_home "$file"
    done

    echo ""
    if [ "$HAS_GUM" = true ]; then
      gum style --foreground 212 --bold "🎉 Sync complete! Files updated in home directory."
    else
      echo "🎉 Dotfiles synced successfully to home directory."
    fi
  fi
}

# Main script starts here

# Prompt user for sync direction
prompt_sync_direction
