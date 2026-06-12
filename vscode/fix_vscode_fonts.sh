#!/usr/bin/env bash

set -euo pipefail

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

# Configure VSCode settings. VS Code settings are JSONC in practice, so jq can
# fail on comments/trailing commas. Use a small Python JSONC normalizer and keep
# a backup before rewriting the file as plain JSON.
echo "Configuring VSCode terminal font..."

SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  echo '{}' > "$SETTINGS_FILE"
fi

python3 - "$SETTINGS_FILE" <<'PY'
import json
import pathlib
import re
import shutil
import sys
from datetime import datetime

path = pathlib.Path(sys.argv[1])
text = path.read_text() if path.exists() else "{}"

def strip_jsonc(source: str) -> str:
    out = []
    i = 0
    in_string = False
    escape = False
    while i < len(source):
        ch = source[i]
        nxt = source[i + 1] if i + 1 < len(source) else ""
        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue
        if ch == "/" and nxt == "/":
            i += 2
            while i < len(source) and source[i] not in "\r\n":
                i += 1
            continue
        if ch == "/" and nxt == "*":
            i += 2
            while i + 1 < len(source) and not (source[i] == "*" and source[i + 1] == "/"):
                i += 1
            i += 2
            continue
        out.append(ch)
        i += 1
    cleaned = "".join(out)
    cleaned = re.sub(r",\s*([}\]])", r"\1", cleaned)
    return cleaned

try:
    settings = json.loads(strip_jsonc(text) or "{}")
except json.JSONDecodeError as exc:
    print(f"Warning: could not parse VS Code settings at {path}: {exc}")
    print("Leaving settings unchanged; set terminal.integrated.fontFamily manually if needed.")
    sys.exit(0)

if not isinstance(settings, dict):
    print(f"Warning: VS Code settings root is not an object in {path}; leaving unchanged.")
    sys.exit(0)

settings["terminal.integrated.fontFamily"] = "MesloLGS NF"
backup = path.with_suffix(path.suffix + ".backup." + datetime.now().strftime("%Y%m%d%H%M%S"))
shutil.copy2(path, backup)
path.write_text(json.dumps(settings, indent=2, sort_keys=True) + "\n")
print(f"Backed up VS Code settings to {backup}")
print("VSCode terminal font set to 'MesloLGS NF'.")
PY

echo "Fonts installed. Please restart VSCode for changes to take effect."
