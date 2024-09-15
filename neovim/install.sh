#!/usr/bin/env bash

set -e

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
  else
    echo "✅ Homebrew is already installed."
  fi
}

# Install Neovim
install_neovim() {
  if ! command_exists nvim; then
    echo "📦 Neovim is not installed. Installing Neovim..."
    brew install neovim
  else
    echo "📦 Neovim is already installed. Updating Neovim..."
    brew upgrade neovim
  fi
}

# Install Node.js
install_node() {
  if ! command_exists node; then
    echo "📦 Node.js is not installed. Installing Node.js..."
    brew install node
  else
    echo "✅ Node.js is already installed."
  fi
}

# Install Vim-Plug for Neovim
install_vim_plug() {
  if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "🔌 Installing Vim-Plug..."
    curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  else
    echo "✅ Vim-Plug is already installed."
  fi
}

# Copy init.vim to the Neovim configuration directory
setup_init_vim() {
  CONFIG_DIR="$HOME/.config/nvim"
  INIT_VIM="$CONFIG_DIR/init.vim"
  REPO_INIT_VIM="$(dirname "$0")/init.vim"

  mkdir -p "$CONFIG_DIR"

  if [ -f "$REPO_INIT_VIM" ]; then
    echo "📄 Copying init.vim to Neovim configuration directory..."
    cp "$REPO_INIT_VIM" "$INIT_VIM"
  else
    echo "⚠️ init.vim not found in the repository. Please ensure it exists in the neovim directory."
  fi
}

# Install Neovim plugins
install_neovim_plugins() {
  echo "🔌 Installing Neovim plugins..."
  nvim +PlugInstall +qall
}

# Set VIMRUNTIME environment variable
set_vimruntime() {
  # Use a dynamic approach to find the Neovim runtime path
  VIMRUNTIME_PATH=$(nvim -e --cmd 'echo $VIMRUNTIME | q' 2>&1)

  echo "🔍 Detected VIMRUNTIME path: $VIMRUNTIME_PATH"

  if [ -d "$VIMRUNTIME_PATH" ]; then
    export VIMRUNTIME="$VIMRUNTIME_PATH"
    
    # Add to both .bash_profile and .zshrc to cover both Bash and Zsh users
    for rc_file in "$HOME/.bash_profile" "$HOME/.zshrc"; do
      if [ -f "$rc_file" ]; then
        if ! grep -q "export VIMRUNTIME=" "$rc_file"; then
          echo "export VIMRUNTIME=\"$VIMRUNTIME_PATH\"" >> "$rc_file"
          echo "📄 Added VIMRUNTIME to $rc_file"
        fi
      fi
    done
    
    echo "✅ VIMRUNTIME set to $VIMRUNTIME_PATH"
  else
    echo "❌ VIMRUNTIME path $VIMRUNTIME_PATH does not exist. Please check your Neovim installation."
  fi
}

# Install ripgrep
install_ripgrep() {
  if ! command_exists rg; then
    echo "📦 ripgrep is not installed. Installing ripgrep..."
    brew install ripgrep
  else
    echo "✅ ripgrep is already installed."
  fi
}

# Check health of the setup
check_health() {
  echo "🔍 Checking health of the setup..."

  for tool in brew nvim node rg; do
    if command_exists $tool; then
      echo "✅ $tool is installed."
    else
      echo "❌ $tool is not installed."
    fi
  done

  if [ -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "✅ Vim-Plug is installed."
  else
    echo "❌ Vim-Plug is not installed."
  fi

  if [ -n "$VIMRUNTIME" ] && [ -d "$VIMRUNTIME" ]; then
    echo "✅ VIMRUNTIME is set correctly."
  else
    echo "❌ VIMRUNTIME is not set correctly."
  fi

  echo "🔍 Health check complete!"
}

# Set environment variables to disable unwanted behavior
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Main function to install Neovim and plugins
echo "🚀 Starting Neovim setup..."
install_brew
install_neovim
install_node
install_vim_plug
setup_init_vim
set_vimruntime
install_neovim_plugins
install_ripgrep

# Run health check
check_health

echo "🎉 Neovim setup complete!"