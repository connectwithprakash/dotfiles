#!/usr/bin/env bash

set -e

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  arm64) VSCODE_ARCH="darwin-arm64" ;;
  x86_64) VSCODE_ARCH="darwin-x64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

VSCODE_URL="https://update.code.visualstudio.com/latest/$VSCODE_ARCH/stable"
VSCODE_FILENAME="VSCode-$VSCODE_ARCH.zip"
VSCODE_APP_PATH="$HOME/Applications/Visual Studio Code.app"
CODE_CMD_PATH="$VSCODE_APP_PATH/Contents/Resources/app/bin"
SYMLINK_PATH="/usr/local/bin/code"

# Check if 'jq' command is available
if ! command -v jq &> /dev/null; then
  echo "The 'jq' command is required for configuring VSCode settings. Please install it first."
  exit 1
fi

# Check if VSCode is already installed
if [ -d "$VSCODE_APP_PATH" ]; then
  echo "Visual Studio Code is already installed."
  read -rp "Do you want to reinstall it? (y/n): " REINSTALL
  if [[ "$REINSTALL" =~ ^[Yy]$ ]]; then
    echo "Reinstalling Visual Studio Code..."
    rm -rf "$VSCODE_APP_PATH"
  else
    echo "Keeping the current installation of Visual Studio Code."
  fi
fi

# Install if not present (or was just removed for reinstall)
if [ ! -d "$VSCODE_APP_PATH" ]; then
  echo "Downloading Visual Studio Code for $VSCODE_ARCH..."
  mkdir -p "$HOME/Applications"
  curl -L "$VSCODE_URL" -o "$VSCODE_FILENAME"
  unzip -q "$VSCODE_FILENAME" -d "$HOME/Applications"
  rm -f "$VSCODE_FILENAME"
  echo "Visual Studio Code installed successfully."
fi

# Add VS Code to PATH in shell configs (if not already present)
if [[ ":$PATH:" != *":$CODE_CMD_PATH:"* ]]; then
  for rc_file in "$HOME/.bash_profile" "$HOME/.zshrc"; do
    if [ -f "$rc_file" ] && ! grep -q "$CODE_CMD_PATH" "$rc_file"; then
      echo "export PATH=\"\$PATH:$CODE_CMD_PATH\"" >> "$rc_file"
    fi
  done
  export PATH="$PATH:$CODE_CMD_PATH"
  echo "VS Code 'code' command added to PATH."
else
  echo "VS Code 'code' command is already in PATH."
fi

# Create symlink for 'code' command (try without sudo first, fall back to sudo)
if [ -L "$SYMLINK_PATH" ] || [ -f "$SYMLINK_PATH" ]; then
  rm -f "$SYMLINK_PATH" 2>/dev/null || sudo rm -f "$SYMLINK_PATH" 2>/dev/null || true
fi
echo "Creating symlink for 'code' command..."
ln -sf "$CODE_CMD_PATH/code" "$SYMLINK_PATH" 2>/dev/null || \
  sudo ln -sf "$CODE_CMD_PATH/code" "$SYMLINK_PATH" 2>/dev/null || \
  echo "Note: Could not create symlink at $SYMLINK_PATH (needs sudo). The 'code' command is available via PATH."

# Verify that the 'code' command is working
if command -v code &> /dev/null; then
  echo "'code' command is available."
else
  echo "'code' command is not available. Please check your PATH settings."
fi

# Execute fix_vscode_fonts.sh script if it exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "$SCRIPT_DIR/fix_vscode_fonts.sh" ]; then
  "$SCRIPT_DIR/fix_vscode_fonts.sh"
fi

echo "Visual Studio Code installation complete."
