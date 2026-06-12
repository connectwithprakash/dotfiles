#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/profiles"
TARGET_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

mkdir -p "$TARGET_DIR"

for profile in "$SOURCE_DIR"/*.json; do
  [ -e "$profile" ] || continue
  cp "$profile" "$TARGET_DIR/$(basename "$profile")"
  echo "Installed iTerm2 dynamic profile: $(basename "$profile")"
done

echo "iTerm2 dynamic profiles installed. Open a new iTerm2 window with profile 'Hermes Nerd Font'."
