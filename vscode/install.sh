#!/bin/zsh

# Define VSCode download URL and filename for Apple Silicon (ARM64)
VSCODE_URL="https://update.code.visualstudio.com/latest/darwin-arm64/stable"
VSCODE_FILENAME="VSCode-darwin-arm64.zip"
VSCODE_APP_PATH="$HOME/Applications/Visual Studio Code.app"
CODE_CMD_PATH="$VSCODE_APP_PATH/Contents/Resources/app/bin"
SYMLINK_PATH="/usr/local/bin/code"

# Check if 'jq' command is available
if ! command -v jq &> /dev/null; then
  echo "The 'jq' command is required for configuring VSCode settings. Please install it or use a different method."
  exit 1
fi

# Check if VSCode is already installed
if [ -d "$VSCODE_APP_PATH" ]; then
  echo "Visual Studio Code is already installed."
  echo "Do you want to reinstall it? (y/n): \c"
  read REINSTALL
  if [[ "$REINSTALL" =~ ^[Yy]$ ]]; then
    echo "Reinstalling Visual Studio Code..."
    rm -rf "$VSCODE_APP_PATH"
    curl -L "$VSCODE_URL" -o "$VSCODE_FILENAME"
    unzip "$VSCODE_FILENAME" -d "$HOME/Applications"
    rm "$VSCODE_FILENAME"
    echo "Visual Studio Code reinstalled successfully."
  else
    echo "Keeping the current installation of Visual Studio Code."
  fi
else
  # Install VSCode
  echo "Downloading and installing Visual Studio Code for Apple Silicon..."
  curl -L "$VSCODE_URL" -o "$VSCODE_FILENAME"
  unzip "$VSCODE_FILENAME" -d "$HOME/Applications"
  rm "$VSCODE_FILENAME"
  echo "Visual Studio Code installed successfully."
fi

# Add VS Code to PATH in both .bash_profile and .zshrc
if [[ ":$PATH:" != *":$CODE_CMD_PATH:"* ]]; then
    echo "export PATH=\$PATH:'$CODE_CMD_PATH'" >> ~/.bash_profile
    echo "export PATH=\$PATH:'$CODE_CMD_PATH'" >> ~/.zshrc
    echo "VS Code command 'code' has been added to PATH."
    echo "Please restart your terminal or run 'source ~/.bash_profile' (for bash) or 'source ~/.zshrc' (for zsh) to apply changes."
else
    echo "VS Code command 'code' is already in PATH."
fi

# Source the updated .zshrc file to update PATH in the current session
source ~/.zshrc

# Ensure 'code' command is available by checking the symlink
if [ -L "$SYMLINK_PATH" ]; then
  echo "Updating existing symlink for 'code' command..."
  sudo rm "$SYMLINK_PATH"
fi

# Create a new symlink to ensure 'code' command is available
echo "Creating symlink for 'code' command..."
sudo ln -sf "$CODE_CMD_PATH/code" "$SYMLINK_PATH"

# Verify that the 'code' command is working
if command -v code &> /dev/null; then
  echo "'code' command is available."
else
  echo "'code' command is not available. Please check your PATH settings and try again."
fi

# Execute fix_vscode_fonts.sh script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
"$SCRIPT_DIR/fix_vscode_fonts.sh"

echo "Visual Studio Code installation is complete. Please run 'configure_vscode.sh' to set up configurations and extensions."
