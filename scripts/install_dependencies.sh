#!/usr/bin/env bash

# Define a list of dependencies to check and install
DEPENDENCIES=(
  "jq"
  "tree"
  "btop++"
  # Add more dependencies as needed
)

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies using Homebrew (for macOS)
install_with_brew() {
  if ! command_exists brew; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "# Setting Homebrew in the PATH" >> "$HOME/.bash_profile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    source "$HOME/.bash_profile"  # Source the updated profile
  fi
  echo "Installing dependencies using Homebrew..."
  brew install "$1"
}

# Function to install dependencies using APT (for Debian-based Linux)
install_with_apt() {
  if ! command_exists apt; then
    echo "APT package manager is not available. Please install dependencies manually."
    exit 1
  fi
  echo "Installing dependencies using APT..."
  sudo apt update
  sudo apt install -y "$1"
}

# Main installation function
install_dependencies() {
  for dep in "${DEPENDENCIES[@]}"; do
    if ! command_exists "$dep"; then
      echo "$dep is not installed. Installing..."
      case "$(uname -s)" in
        Darwin)
          install_with_brew "$dep"
          ;;
        Linux)
          install_with_apt "$dep"
          ;;
        *)
          echo "Unsupported operating system. Please install $dep manually."
          exit 1
          ;;
      esac
    else
      echo "$dep is already installed."
    fi
  done
}

# Execute the installation function
install_dependencies

echo "Dependency installation complete."
