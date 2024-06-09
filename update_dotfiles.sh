#!/bin/bash

DOTFILES_DIR=$(dirname "$(realpath "$0")")
ZSH_DIR="$DOTFILES_DIR/zsh"
DOTFILES=("$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.zsh_history" "$HOME/.aliases" "$HOME/.bash_profile" "$HOME/.gitconfig" "$HOME/.gitignore" "$HOME/.vimrc")

compare_files() {
  local file1="$1"
  local file2="$2"
  if ! diff "$file1" "$file2" &>/dev/null; then
    return 1
  else
    return 0
  fi
}

update_required=false
for file in "${DOTFILES[@]}"; do
  filename=$(basename "$file")
  if [[ "$filename" == .zshrc || "$filename" == .p10k.zsh || "$filename" == .zsh_history ]]; then
    dotfile="$ZSH_DIR/$filename"
  else
    dotfile="$DOTFILES_DIR/$filename"
  fi

  if [ -f "$dotfile" ]; then
    if ! compare_files "$file" "$dotfile"; then
      echo "Update available for $filename."
      update_required=true
    fi
  else
    echo "$filename is not in the dotfiles repository."
    update_required=true
  fi
done

if $update_required; then
  read -p "Do you want to update the dotfiles in the repository? (y/n): " answer
  case $answer in
    [Yy]* )
      for file in "${DOTFILES[@]}"; do
        filename=$(basename "$file")
        if [[ "$filename" == .zshrc || "$filename" == .p10k.zsh || "$filename" == .zsh_history ]]; then
          dotfile="$ZSH_DIR/$filename"
        else
          dotfile="$DOTFILES_DIR/$filename"
        fi
        echo "Updating $filename in the repository..."
        cp "$file" "$dotfile"
      done
      echo "Dotfiles updated in the repository."
      ;;
    [Nn]* )
      echo "No updates were made to the repository."
      ;;
    * )
      echo "Invalid input. No updates were made to the repository."
      ;;
  esac
else
  echo "No updates are required."
fi
