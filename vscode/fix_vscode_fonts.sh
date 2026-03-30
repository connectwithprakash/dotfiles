#!/usr/bin/env bash

set -e

# Define the font directory and font files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_DIR="$SCRIPT_DIR/fonts"
FONT_FILES=(
  "MesloLGS NF Regular.ttf"
  "MesloLGS NF Bold.ttf"
  "MesloLGS NF Italic.ttf"
  "MesloLGS NF Bold Italic.ttf"
)

# Check if the font directory exists
if [ ! -d "$FONT_DIR" ]; then
  echo "The font directory $FONT_DIR does not exist. Skipping font installation."
  exit 0
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install the fonts
echo "Installing fonts from $FONT_DIR..."
mkdir -p "$HOME/Library/Fonts"
for font_file in "${FONT_FILES[@]}"; do
  if [ -f "$FONT_DIR/$font_file" ]; then
    cp "$FONT_DIR/$font_file" "$HOME/Library/Fonts/"
    echo "Installed $font_file"
  else
    echo "$font_file does not exist in $FONT_DIR. Skipping..."
  fi
done

# Check if VSCode is installed
if ! command_exists code; then
  echo "VSCode is not installed. Skipping settings configuration."
  exit 0
fi

# Configure VSCode settings using jq (proper JSON handling)
echo "Configuring VSCode terminal font..."

SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  echo '{}' > "$SETTINGS_FILE"
fi

if command_exists jq; then
  # Use jq for safe JSON manipulation
  jq '. + {"terminal.integrated.fontFamily": "MesloLGS NF"}' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
    && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
  echo "VSCode terminal font set to 'MesloLGS NF' via jq."
else
  echo "Warning: jq not found. Please manually set terminal.integrated.fontFamily to 'MesloLGS NF' in VS Code settings."
fi

echo "Fonts installed. Please restart VSCode for changes to take effect."
