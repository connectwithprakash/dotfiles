#!/usr/bin/env bash

# Define a list of pipx-managed Python packages to install
PIPX_DEPENDENCIES=(
  "black"
  "flake8"
  "poetry"
  # Add more pipx packages as needed
)

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install pipx
install_pipx() {
  if ! command_exists pipx; then
    echo "pipx is not installed. Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    # Refresh the PATH for the current session
    export PATH="$PATH:$HOME/.local/bin"
  fi
}

# Function to install pipx-managed Python packages
install_pipx_dependencies() {
  install_pipx
  for pkg in "${PIPX_DEPENDENCIES[@]}"; do
    if ! pipx list | grep -q "$pkg"; then
      echo "$pkg is not installed. Installing with pipx..."
      pipx install "$pkg"
    else
      echo "$pkg is already installed."
    fi
  done
}

# Execute the installation function
install_pipx_dependencies

echo "Pipx dependency installation complete."
