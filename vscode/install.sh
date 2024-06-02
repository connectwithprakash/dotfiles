#!/bin/bash

# Define VSCode download URL and filename for Apple Silicon (ARM64)
VSCODE_URL="https://update.code.visualstudio.com/latest/darwin-arm64/stable"
VSCODE_FILENAME="VSCode-darwin-arm64.zip"
VSCODE_APP_PATH="/Applications/Visual Studio Code.app"
CODE_CMD_PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Check if 'jq' command is available
if ! command -v jq &> /dev/null; then
  echo "The 'jq' command is required for configuring VSCode settings. Please install it or use a different method."
  exit 1
fi

# Check if VSCode is already installed
if [ -d "$VSCODE_APP_PATH" ]; then
  echo "Visual Studio Code is already installed."
else
  # Install VSCode
  echo "Downloading and installing Visual Studio Code for Apple Silicon..."
  curl -L "$VSCODE_URL" -o "$VSCODE_FILENAME"
  unzip "$VSCODE_FILENAME" -d "$HOME/Applications"
  rm "$VSCODE_FILENAME"
  echo "Visual Studio Code installed successfully."
fi

# Ensure 'code' command is available
if ! command -v code &> /dev/null; then
  echo "Adding 'code' command to PATH..."
  if [ ! -d "$HOME/Applications" ]; then
    mkdir -p "$HOME/Applications"
  fi

  # Add 'code' to PATH if not already present
  if ! grep -q "$CODE_CMD_PATH" "$HOME/.zshrc"; then
    echo "export PATH=\"\$PATH:$CODE_CMD_PATH\"" >> "$HOME/.zshrc"
    # Refresh the PATH for the current session
    source "$HOME/.zshrc"
    echo "'code' command added to PATH. Please restart your terminal for the changes to take effect."
  else
    echo "'code' command is already in PATH."
  fi

  # Create a symlink to ensure 'code' command is available
  if [ ! -L /usr/local/bin/code ]; then
    echo "Creating symlink for 'code' command..."
    sudo ln -s "$CODE_CMD_PATH/code" /usr/local/bin/code
    echo "Symlink created for 'code' command."
  else
    echo "Symlink for 'code' command already exists."
  fi
else
  echo "'code' command is already available."
fi

# Verify that the 'code' command is working
if command -v code &> /dev/null; then
  echo "'code' command is available."
else
  echo "'code' command is not available. Please check your PATH settings and try again."
fi

echo "Visual Studio Code installation is complete. Please run 'configure_vscode.sh' to set up configurations and extensions."

