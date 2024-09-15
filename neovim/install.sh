#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not installed
install_brew() {
  if ! command_exists brew; then
    echo "🍺 Homebrew is not installed. 🌟 Initiating Homebrew installation..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "🔧 Configuring Homebrew in the PATH..."
    echo "# Setting Homebrew in the PATH" >> "$HOME/.bash_profile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    source "$HOME/.bash_profile"
    echo "✅ Homebrew installation complete!"
  fi
}

# Install Neovim
install_neovim() {
  if ! command_exists nvim; then
    echo "Neovim is not installed. Installing Neovim..."
    brew install neovim
  else
    echo "Neovim is already installed."
  fi
}

# Install Vim-Plug for Neovim
install_vim_plug() {
  if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "Installing Vim-Plug..."
    curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  else
    echo "Vim-Plug is already installed."
  fi
}

# Install Neovim plugins
install_neovim_plugins() {
  echo "Installing Neovim plugins..."
  nvim +PlugInstall +qall
}

# Main function to install Neovim and plugins
install_brew
install_neovim
install_vim_plug
install_neovim_plugins

echo "🎉 Neovim setup complete!"