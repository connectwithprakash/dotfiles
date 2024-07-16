#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure script is running with a valid PATH
source "$HOME/.bash_profile" || source "$HOME/.zshrc"

# Install pipx if not already installed
if ! command_exists pipx; then
  echo "pipx is not installed. Installing pipx using Homebrew..."
  if ! command_exists brew; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install pipx
  # Add pipx to PATH
  export PATH="$PATH:$HOME/.local/bin"
else
  echo "pipx is already installed."
fi

# Define a list of pipx-managed dependencies to check and install
PIPX_DEPENDENCIES=(
  "black"
  "flake8"
  "poetry"
  # Add more pipx dependencies as needed
)

# Function to install pipx-managed dependencies
install_pipx_dependencies() {
  for dep in "${PIPX_DEPENDENCIES[@]}"; do
    if ! pipx list | grep -q "$dep"; then
      echo "$dep is not installed. Installing with pipx..."
      pipx install "$dep"
    else
      echo "$dep is already installed."
    fi
  done
}

# Execute the installation function
install_pipx_dependencies

echo "Pipx dependency installation complete."
