#!/usr/bin/env bash
# Shared managed dotfile mapping for status and sync commands.

# Repo-relative paths for files managed by this dotfiles repository.
# shellcheck disable=SC2034 # Sourced by dotfiles and update_dotfiles.sh.
managed_dotfiles=(
  ".aliases"
  ".bash_profile"
  ".bash_prompt"
  ".editorconfig"
  ".exports"
  ".functions"
  ".gitconfig"
  ".gitignore"
  ".inputrc"
  ".path"
  ".tmux.conf"
  "neovim/init.lua"
  "zsh/.zshrc"
  "zsh/starship.toml"
  "hermes/config.yaml"
)

# Map a repo-relative managed path to its live home path.
get_home_path() {
  local file="$1"

  case "$file" in
    zsh/.zshrc) echo "$HOME/.zshrc" ;;
    zsh/starship.toml) echo "$HOME/.config/starship.toml" ;;
    neovim/init.lua) echo "$HOME/.config/nvim/init.lua" ;;
    hermes/config.yaml) echo "$HOME/.hermes/config.yaml" ;;
    *) echo "$HOME/$file" ;;
  esac
}

# Human-readable label for status and sync output.
get_dotfile_label() {
  local file="$1"
  echo "$file"
}
