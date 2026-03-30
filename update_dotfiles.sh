#!/usr/bin/env bash

set -e

# Define root directory (portable, no realpath needed)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared library
source "$ROOT_DIR/scripts/lib.sh"

# Ensure root directory exists
if [ ! -d "$ROOT_DIR" ]; then
  echo "Root directory '$ROOT_DIR' not found."
  exit 1
fi

# List dot files in the project structure
dotfiles=(
  ".aliases"
  ".bash_profile"
  ".bash_prompt"
  ".editorconfig"
  ".exports"
  ".functions"
  ".gitconfig"
  ".gitignore"
  ".inputrc"
  ".tmux.conf"
  ".vimrc"
)

# Additional dot files inside zsh directory with their relative paths
zsh_dotfiles=(
  "zsh/.zshrc"
  "zsh/starship.toml"
)

# Map repo path to home path (handles special cases)
get_home_path() {
  local file="$1"
  local home_file="${file#zsh/}"
  case "$home_file" in
    starship.toml) echo "$HOME/.config/starship.toml" ;;
    *) echo "$HOME/$home_file" ;;
  esac
}

# Function to show differences in files
show_diff() {
  local file="$1"
  local repo_path="$ROOT_DIR/$file"
  local home_path
  home_path="$(get_home_path "$file")"

  if ! diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
    if [ "$HAS_GUM" = true ]; then
      gum style --border rounded --border-foreground 212 --padding "0 1" "Differences in: $home_file"
      echo ""
      echo "Home: $home_path"
      echo "Repo: $repo_path"
      echo ""
    else
      echo "Differences in dotfile: $home_file"
      echo "---------------------------------"
      echo "File path in home directory: $home_path"
      echo "File path in dotfiles repo: $repo_path"
      echo ""
    fi

    diff -u "$home_path" "$repo_path" || true
    echo ""
  fi
}

# Function to sync files from home directory to repo
sync_to_repo() {
  local file="$1"
  local repo_path="$ROOT_DIR/$file"
  local home_path
  home_path="$(get_home_path "$file")"

  if [ -f "$home_path" ]; then
    if ! diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
      mkdir -p "$(dirname "$repo_path")"
      if [ "$HAS_GUM" = true ]; then
        gum spin --spinner dot --title "Syncing $home_file..." -- sleep 0.2
      fi
      cp "$home_path" "$repo_path"
      echo "Synced $home_file to repository"
    else
      echo "No changes in $home_file (skipped)"
    fi
  fi
}

# Function to sync files from repo to home directory
sync_to_home() {
  local file="$1"
  local repo_path="$ROOT_DIR/$file"
  local home_path
  home_path="$(get_home_path "$file")"

  if [ -f "$repo_path" ]; then
    if ! diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
      backup_file "$home_path"
      if [ "$HAS_GUM" = true ]; then
        gum spin --spinner dot --title "Syncing $home_file..." -- sleep 0.2
      fi
      cp "$repo_path" "$home_path"
      echo "Synced $home_file to home directory"
    else
      echo "No changes in $home_file (skipped)"
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
      "Dotfiles Sync Manager" \
      "" \
      "Choose your sync direction:"

    DIRECTION=$(gum choose \
      "Home -> Repository" \
      "Repository -> Home")

    case "$DIRECTION" in
      *"Home -> Repository"*) sync_home_to_repo;;
      *"Repository -> Home"*) sync_repo_to_home;;
    esac
  else
    echo "Choose Your Sync Direction"
    echo "1) Home to Repository"
    echo "2) Repository to Home"
    while true; do
      read -rp "Enter your choice (1/2): " direction
      case $direction in
        1 ) sync_home_to_repo; break;;
        2 ) sync_repo_to_home; break;;
        * ) echo "Please choose '1' for Home to Repository or '2' for Repository to Home.";;
      esac
    done
  fi
}

# Function to check if a file has changes
check_file_status() {
  local file="$1"
  local repo_path="$ROOT_DIR/$file"
  local home_path
  home_path="$(get_home_path "$file")"

  if [ -f "$home_path" ] && [ -f "$repo_path" ]; then
    if diff -q "$home_path" "$repo_path" >/dev/null 2>&1; then
      echo "unchanged"
    else
      echo "modified"
    fi
  elif [ -f "$home_path" ] || [ -f "$repo_path" ]; then
    echo "modified"
  else
    echo "missing"
  fi
}

# Function to prompt user to select specific dotfiles
prompt_select_dotfiles() {
  selected_dotfiles=()

  if [ "$HAS_GUM" = true ]; then
    echo ""
    gum style \
      --border double \
      --border-foreground 212 \
      --padding "0 1" \
      --margin "0" \
      "Select Dotfiles to Sync" \
      "" \
      "* = modified  |  - = unchanged"

    echo ""

    # Build selection list with status indicators
    selection_list=()

    for file in "${dotfiles[@]}" "${zsh_dotfiles[@]}"; do
      status=$(check_file_status "$file")
      if [ "$status" = "modified" ]; then
        selection_list+=("* $file")
      else
        selection_list+=("- $file")
      fi
    done

    while IFS= read -r line; do
      if [[ "$line" == \*\ * ]] || [[ "$line" == -\ * ]]; then
        file="${line#\* }"
        file="${file#- }"
        selected_dotfiles+=("$file")
      fi
    done < <(gum choose --no-limit --height 20 "${selection_list[@]}")

    if [ ${#selected_dotfiles[@]} -eq 0 ]; then
      echo "No dotfiles selected. Aborting."
      exit 0
    fi
  else
    for file in "${dotfiles[@]}" "${zsh_dotfiles[@]}"; do
      if prompt_yes_no "Do you want to sync $file?"; then
        selected_dotfiles+=("$file")
      fi
    done

    if [ ${#selected_dotfiles[@]} -eq 0 ]; then
      echo "No dotfiles selected. Aborting."
      exit 0
    fi
  fi
}

# Sync dotfiles from home directory to repository
sync_home_to_repo() {
  prompt_select_dotfiles

  echo ""
  echo "Selected ${#selected_dotfiles[@]} file(s) for sync"
  echo ""

  if prompt_yes_no "Preview changes before syncing?"; then
    for file in "${selected_dotfiles[@]}"; do
      show_diff "$file"
    done

    if prompt_yes_no "Proceed with sync?"; then
      echo ""
      for file in "${selected_dotfiles[@]}"; do
        sync_to_repo "$file"
      done
      echo ""
      echo "Sync complete! Files updated in repository."
    else
      echo "Sync aborted."
    fi
  else
    echo ""
    for file in "${selected_dotfiles[@]}"; do
      sync_to_repo "$file"
    done
    echo ""
    echo "Sync complete! Files updated in repository."
  fi
}

# Sync dotfiles from repository to home directory
sync_repo_to_home() {
  prompt_select_dotfiles

  echo ""
  echo "Selected ${#selected_dotfiles[@]} file(s) for sync"
  echo ""

  if prompt_yes_no "Preview changes before syncing?"; then
    for file in "${selected_dotfiles[@]}"; do
      show_diff "$file"
    done

    if prompt_yes_no "Proceed with sync?"; then
      echo ""
      for file in "${selected_dotfiles[@]}"; do
        sync_to_home "$file"
      done
      echo ""
      echo "Sync complete! Files updated in home directory."
    else
      echo "Sync aborted."
    fi
  else
    echo ""
    for file in "${selected_dotfiles[@]}"; do
      sync_to_home "$file"
    done
    echo ""
    echo "Sync complete! Files updated in home directory."
  fi
}

# Main script starts here
prompt_sync_direction
