#!/usr/bin/env bash

# Claude Code Configuration Sync Script
# Bidirectional sync between dotfiles repository and ~/.claude/

set -e

# Define directories
DOTFILES_CLAUDE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CLAUDE_DIR="$HOME/.claude"

# Source shared library
DOTFILES_ROOT="$(cd "$DOTFILES_CLAUDE_DIR/.." && pwd)"
if [ -f "$DOTFILES_ROOT/scripts/lib.sh" ]; then
  source "$DOTFILES_ROOT/scripts/lib.sh"
else
  # Minimal fallback if lib.sh not available
  command_exists() { command -v "$1" >/dev/null 2>&1; }
  prompt_yes_no() {
    while true; do
      read -rp "$1 (y/n): " yn
      case $yn in [Yy]* ) return 0;; [Nn]* ) return 1;; * ) echo "Please answer yes or no.";; esac
    done
  }
  backup_file() { :; }
fi

# Helper functions
file_exists() { [ -f "$1" ]; }
dir_exists() { [ -d "$1" ]; }

show_diff() {
  local file1="$1" file2="$2" label1="$3" label2="$4"
  if file_exists "$file1" && file_exists "$file2"; then
    if ! diff -q "$file1" "$file2" >/dev/null; then
      echo "Differences in: $(basename "$file1")"
      echo "---------------------------------"
      echo "$label1: $file1"
      echo "$label2: $file2"
      echo ""
      diff -u "$file1" "$file2" || true
      echo ""
    fi
  fi
}

# Function to sync from repository to global (~/.claude/)
sync_repo_to_global() {
  echo "Syncing from repository to global ~/.claude/..."

  # Create global .claude directory if it doesn't exist
  if ! dir_exists "$GLOBAL_CLAUDE_DIR"; then
    echo "Creating global Claude Code directory: $GLOBAL_CLAUDE_DIR"
    mkdir -p "$GLOBAL_CLAUDE_DIR"
  fi

  # Show diffs if requested (skip in force mode)
  if [ "$FORCE_MODE" != true ]; then
    if prompt_yes_no "Preview changes before syncing?"; then
      if file_exists "$DOTFILES_CLAUDE_DIR/settings.json" && file_exists "$GLOBAL_CLAUDE_DIR/settings.json"; then
        show_diff "$GLOBAL_CLAUDE_DIR/settings.json" "$DOTFILES_CLAUDE_DIR/settings.json" "Current global" "Repository"
      fi

      if ! prompt_yes_no "Proceed with sync?"; then
        echo "Sync cancelled."
        return
      fi
    fi
  fi

  # Sync settings.json
  if file_exists "$DOTFILES_CLAUDE_DIR/settings.json"; then
    echo "⚙️  Syncing settings.json..."
    cp "$DOTFILES_CLAUDE_DIR/settings.json" "$GLOBAL_CLAUDE_DIR/settings.json"
    echo "✅ settings.json synced to global"
  else
    echo "⚠️  settings.json not found in repository"
  fi

  # Skills are managed by the agent-skills repo, not synced from here.
  # Probe the conventional location and surface the next step explicitly so a
  # fresh checkout doesn't silently end up with no skills wired.
  AGENT_SKILLS_DIR="$HOME/Developer/agent-skills"
  AGENT_SKILLS_REPO="https://github.com/connectwithprakash/agent-skills"
  if [ -d "$AGENT_SKILLS_DIR" ]; then
    echo "💡 Skills repo detected at $AGENT_SKILLS_DIR"
    echo "    Wire skills with: bash $AGENT_SKILLS_DIR/setup/bootstrap.sh"
  else
    echo "⚠️  agent-skills not found at $AGENT_SKILLS_DIR -- skills will not be wired."
    echo "    To install:"
    echo "      git clone $AGENT_SKILLS_REPO $AGENT_SKILLS_DIR"
    echo "      bash $AGENT_SKILLS_DIR/setup/bootstrap.sh"
  fi

  echo "🎉 Claude Code configurations synced successfully to ~/.claude/!"
}

# Function to sync from global to repository
sync_global_to_repo() {
  echo "🔧 Syncing from global ~/.claude/ to repository..."

  if ! dir_exists "$GLOBAL_CLAUDE_DIR"; then
    echo "❌ Global ~/.claude/ directory not found. Nothing to sync."
    return
  fi

  # Show diffs if requested
  if prompt_yes_no "👀 Do you want to see the changes before syncing?"; then
    if file_exists "$GLOBAL_CLAUDE_DIR/settings.json" && file_exists "$DOTFILES_CLAUDE_DIR/settings.json"; then
      show_diff "$DOTFILES_CLAUDE_DIR/settings.json" "$GLOBAL_CLAUDE_DIR/settings.json" "Current repo" "Global"
    fi

    # Confirm sync
    if ! prompt_yes_no "🔄 Do you want to proceed with the sync?"; then
      echo "❌ Sync cancelled."
      return
    fi
  fi

  # Sync settings.json
  if file_exists "$GLOBAL_CLAUDE_DIR/settings.json"; then
    echo "⚙️  Syncing settings.json..."
    cp "$GLOBAL_CLAUDE_DIR/settings.json" "$DOTFILES_CLAUDE_DIR/settings.json"
    echo "✅ settings.json synced to repository"
  else
    echo "⚠️  settings.json not found in global ~/.claude/"
  fi

  # Skills are managed by the agent-skills repo, not this dotfiles repo.
  # Edits to skills should land in agent-skills directly so all wired tools
  # (Claude Code, Codex, Hermes) pick them up via the symlink/external_dirs setup.
  echo "ℹ️  Skills are managed separately. Edit them in:"
  echo "    \$HOME/Developer/agent-skills (https://github.com/connectwithprakash/agent-skills)"

  echo "🎉 Claude Code configurations synced successfully to repository!"
}

# Function to prompt for sync direction
prompt_sync_direction() {
  echo "🌟✨ Choose Your Sync Direction ✨🌟"
  echo "1) Repository to Global (~/.claude/) 📁➡️🏠"
  echo "2) Global to Repository (~/.claude/ ➡️📁)"
  while true; do
    read -rp "Enter your choice (1/2): " direction
    case $direction in
      1 ) sync_repo_to_global; break;;
      2 ) sync_global_to_repo; break;;
      * ) echo "❗ Please choose '1' for Repository to Global or '2' for Global to Repository.";;
    esac
  done
}

# Main execution
echo "🚀 Claude Code Configuration Sync"
echo "Repository: $DOTFILES_CLAUDE_DIR"
echo "Global: $GLOBAL_CLAUDE_DIR"
echo ""

# Check if running in automated mode (--force or called from bootstrap)
FORCE_MODE=false
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
  FORCE_MODE=true
  sync_repo_to_global
else
  # Interactive mode: prompt for direction
  prompt_sync_direction
fi

echo ""
echo "📝 Note: Runtime data (history, todos, debug logs) are managed by Claude Code and not synced."
