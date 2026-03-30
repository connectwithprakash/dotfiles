#!/usr/bin/env bash

set -e

DOTFILES_ZSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_package() {
  local package="$1"
  if command_exists brew; then
    brew install "$package"
  elif command_exists apt-get; then
    sudo apt-get update && sudo apt-get install -y "$package"
  else
    echo "Package manager not supported. Please install $package manually."
    exit 1
  fi
}

set_zsh_in_bashrc() {
  local bashrc_file="$HOME/.bashrc"
  touch "$bashrc_file"
  if ! grep -q "exec zsh" "$bashrc_file"; then
    echo "exec zsh" >> "$bashrc_file"
    echo "Added 'exec zsh' to $bashrc_file"
  else
    echo "'exec zsh' is already present in $bashrc_file"
  fi
}

# Install Zsh
if ! command_exists zsh; then
  echo "Installing Zsh..."
  install_package zsh
else
  echo "Zsh is already installed."
fi

# Set Zsh as default shell
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "Changing the default shell to Zsh..."
  if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_PATH" "$USER"
else
  echo "Default shell is already Zsh."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

# Install Starship prompt (replaces archived Powerlevel10k)
if ! command_exists starship; then
  echo "Installing Starship prompt..."
  if command_exists brew; then
    brew install starship
  else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
else
  echo "Starship is already installed."
fi

# Install zoxide (smarter cd)
if ! command_exists zoxide; then
  echo "Installing zoxide..."
  install_package zoxide
else
  echo "zoxide is already installed."
fi

# Copy .zshrc
echo "Copying .zshrc..."
cp "$DOTFILES_ZSH_DIR/.zshrc" "$HOME/.zshrc"

# Copy Starship config
echo "Copying Starship configuration..."
mkdir -p "$HOME/.config"
cp "$DOTFILES_ZSH_DIR/starship.toml" "$HOME/.config/starship.toml"

# Remove legacy Powerlevel10k config if present
[ -f "$HOME/.p10k.zsh" ] && rm -f "$HOME/.p10k.zsh" && echo "Removed legacy .p10k.zsh"
[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ] && rm -rf "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" && echo "Removed legacy Powerlevel10k theme"

# Install Zsh plugins
echo "Installing Zsh plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"
plugins=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-completions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-history-substring-search"
)

for plugin in "${plugins[@]}"; do
  plugin_dir="$(basename "$plugin")"
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_dir" ]; then
    echo "Installing $plugin_dir..."
    git clone --depth=1 "https://github.com/$plugin" "$ZSH_CUSTOM/plugins/$plugin_dir"
  else
    echo "$plugin_dir is already installed."
  fi
done

# Set Zsh in .bashrc for VS Code compatibility
set_zsh_in_bashrc

echo "Zsh setup complete!"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
