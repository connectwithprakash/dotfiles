#!/usr/bin/env bash

set -e

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure Homebrew is available
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Install pipx if not already installed
if ! command_exists pipx; then
  echo "pipx is not installed. Installing using Homebrew..."
  if ! command_exists brew; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
  fi
  brew install pipx
  pipx ensurepath
fi

# Ensure pipx bin dir is on PATH
export PATH="$PATH:$HOME/.local/bin"

# Define a list of pipx-managed dependencies to check and install
PIPX_DEPENDENCIES=(
  "black"
  "flake8"
  "poetry"
)

# Function to install pipx-managed dependencies
install_pipx_dependencies() {
  for dep in "${PIPX_DEPENDENCIES[@]}"; do
    if ! pipx list --short 2>/dev/null | grep -q "^${dep} "; then
      echo "$dep is not installed. Installing with pipx..."
      pipx install "$dep"
    else
      echo "$dep is already installed."
    fi
  done
}

install_pipx_dependencies

echo "Pipx dependency installation complete."
