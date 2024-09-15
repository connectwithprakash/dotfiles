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

# Install Node.js
install_node() {
  if ! command_exists node; then
    echo "Node.js is not installed. Installing Node.js..."
    brew install node
  else
    echo "Node.js is already installed."
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

# Copy init.vim to the Neovim configuration directory
setup_init_vim() {
  CONFIG_DIR="$HOME/.config/nvim"
  INIT_VIM="$CONFIG_DIR/init.vim"
  REPO_INIT_VIM="$(dirname "$0")/init.vim"

  if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating Neovim configuration directory..."
    mkdir -p "$CONFIG_DIR"
  fi

  if [ -f "$REPO_INIT_VIM" ]; then
    echo "Copying init.vim to Neovim configuration directory..."
    cp "$REPO_INIT_VIM" "$INIT_VIM"
  else
    echo "⚠️ init.vim not found in the repository. Please ensure it exists in the neovim directory."
  fi
}

# Install Neovim plugins
install_neovim_plugins() {
  echo "Installing Neovim plugins..."
  nvim +PlugInstall +qall
}

# Set VIMRUNTIME environment variable if not already set
set_vimruntime() {
  if [ -z "$VIMRUNTIME" ]; then
    VIM_VERSION=$(nvim --version | head -n 1 | awk '{print $2}')
    export VIMRUNTIME="/opt/homebrew/Cellar/neovim/$VIM_VERSION/share/nvim/runtime"
    
    if ! grep -q 'export VIMRUNTIME=' "$HOME/.bash_profile"; then
      echo "export VIMRUNTIME=\"$VIMRUNTIME\"" >> "$HOME/.bash_profile"
      echo "📄 Added VIMRUNTIME to .bash_profile"
    fi
    
    if ! grep -q 'export VIMRUNTIME=' "$HOME/.zshrc"; then
      echo "export VIMRUNTIME=\"$VIMRUNTIME\"" >> "$HOME/.zshrc"
      echo "📄 Added VIMRUNTIME to .zshrc"
    fi
    
    source "$HOME/.bash_profile" || source "$HOME/.zshrc"
    echo "✅ VIMRUNTIME set to $VIMRUNTIME"
  else
    echo "ℹ️ VIMRUNTIME is already set to $VIMRUNTIME"
  fi
}

# Main function to install Neovim and plugins
install_brew
install_neovim
install_node
install_vim_plug
setup_init_vim
install_neovim_plugins
set_vimruntime

echo "🎉 Neovim setup complete!"