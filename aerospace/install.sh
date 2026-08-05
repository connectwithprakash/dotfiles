#!/usr/bin/env bash

# Ensure Homebrew is in PATH
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_brew() {
  if ! command_exists brew; then
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "Homebrew installation complete!"
  else
    echo "Homebrew is already installed."
  fi
}

install_aerospace() {
  if [ -d "/Applications/AeroSpace.app" ]; then
    echo "AeroSpace is already installed. Upgrading..."
    brew upgrade --cask nikitabobko/tap/aerospace || true
  else
    echo "Installing AeroSpace..."
    brew install --cask nikitabobko/tap/aerospace
  fi
}

setup_config() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [ -f "$script_dir/aerospace.toml" ]; then
    echo "Copying aerospace.toml to \$HOME/.aerospace.toml..."
    cp "$script_dir/aerospace.toml" "$HOME/.aerospace.toml"
  else
    echo "Warning: aerospace.toml not found in the repository."
  fi
}

check_health() {
  echo "Checking health of the setup..."

  if [ -d "/Applications/AeroSpace.app" ]; then
    echo "  [ok] AeroSpace.app is installed."
  else
    echo "  [missing] AeroSpace.app is not installed."
  fi

  if [ -f "$HOME/.aerospace.toml" ]; then
    echo "  [ok] ~/.aerospace.toml exists."
  else
    echo "  [missing] ~/.aerospace.toml not found."
  fi

  echo "Health check complete!"
  echo "Note: AeroSpace requires Accessibility permission (System Settings ->"
  echo "Privacy & Security -> Accessibility). macOS prompts for this on first"
  echo "launch -- there is no CLI step to grant it in advance."
}

export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

echo "Starting AeroSpace setup..."
install_brew
install_aerospace
setup_config
check_health
echo "AeroSpace setup complete! Launch it from /Applications to grant Accessibility permission."
