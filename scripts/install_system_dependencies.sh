#!/usr/bin/env bash

# Define a list of system dependencies to check and install
SYSTEM_DEPENDENCIES=(
  "jq"
  "tree"
  "btop"
  "tmux"
  "stats"
  "pipx"
  "neovim"
  # Add more system dependencies as needed
)

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew (for macOS)
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

# Function to install system dependencies using Homebrew (for macOS)
install_with_brew() {
  install_brew
  echo "🔧 Installing $1 using Homebrew... 🍺"
  brew install "$1"
  echo "✅ $1 installation complete!"
}

# Function to install system dependencies using APT (for Debian-based Linux)
install_with_apt() {
  if ! command_exists apt; then
    echo "⚠️ APT package manager is not available. ❌ Please install dependencies manually."
    exit 1
  fi
  echo "🔧 Installing $1 using APT... 🐧"
  sudo apt update
  sudo apt install -y "$1"
  echo "✅ $1 installation complete!"
}

# Main function to install system dependencies
install_system_dependencies() {
  for dep in "${SYSTEM_DEPENDENCIES[@]}"; do
    if ! command_exists "$dep"; then
      echo "🚀 $dep is not installed. 🌟 Initiating installation..."
      case "$(uname -s)" in
        Darwin)
          install_with_brew "$dep"
          ;;
        Linux)
          install_with_apt "$dep"
          ;;
        *)
          echo "❌ Unsupported operating system. Please install $dep manually."
          exit 1
          ;;
      esac
    else
      echo "✅ $dep is already installed. Skipping..."
    fi
  done
}

# Execute the installation function
install_system_dependencies

echo "🎉 All system dependencies have been successfully installed! 🚀"