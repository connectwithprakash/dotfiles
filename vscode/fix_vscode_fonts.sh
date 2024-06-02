#!/bin/bash

# Define the font directory and font files
SCRIPT_DIR=$(dirname "$(realpath "$0")")
FONT_DIR="$SCRIPT_DIR/fonts"
FONT_FILES=(
  "MesloLGS NF Regular.ttf"
  "MesloLGS NF Bold.ttf"
  "MesloLGS NF Italic.ttf"
  "MesloLGS NF Bold Italic.ttf"
)

# Check if the font directory exists
if [ ! -d "$FONT_DIR" ]; then
  echo "The font directory $FONT_DIR does not exist. Please make sure the fonts are in the correct directory."
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if 'sed' command is available
if ! command_exists sed; then
  echo "The 'sed' command is required but is not installed. Please install it and try again."
  exit 1
fi

# Install the fonts
echo "Installing fonts from $FONT_DIR..."
mkdir -p ~/Library/Fonts
for font_file in "${FONT_FILES[@]}"; do
  if [ -f "$FONT_DIR/$font_file" ]; then
    cp "$FONT_DIR/$font_file" ~/Library/Fonts/
    echo "Installed $font_file"
  else
    echo "$font_file does not exist in $FONT_DIR. Skipping..."
  fi
done

# Check if VSCode is installed
if ! command -v code &> /dev/null; then
  echo "VSCode is not installed. Please install VSCode first."
  exit 1
fi

# Configure VSCode settings
echo "Configuring VSCode terminal font..."

# Create a settings file for VSCode if it doesn't exist
SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  echo "{}" > "$SETTINGS_FILE"
fi

# Remove all existing entries of "terminal.integrated.fontFamily"
sed -i '' '/"terminal.integrated.fontFamily":/d' "$SETTINGS_FILE"

# Add or update the terminal font family setting in VSCode
# Add the new setting before the closing curly brace
if grep -q '^}$' "$SETTINGS_FILE"; then
  sed -i '' -e '$i\
  ,\
  "terminal.integrated.fontFamily": "MesloLGS NF"' "$SETTINGS_FILE"
else
  # If there are multiple lines, ensure proper JSON formatting
  sed -i '' -e '$a\
  ,\
  "terminal.integrated.fontFamily": "MesloLGS NF"' "$SETTINGS_FILE"
fi

# Notify the user
echo "Fonts installed and VSCode terminal font set to 'MesloLGS NF'. Please restart VSCode for changes to take effect."

# Open VSCode to show the settings file
echo "Opening VSCode settings.json..."
if ! code "$SETTINGS_FILE"; then
  echo "Failed to open VSCode settings file. Please open $SETTINGS_FILE manually."
fi

