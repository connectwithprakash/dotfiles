#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/profiles"
TARGET_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
AUTOLAUNCH_SOURCE_DIR="$SCRIPT_DIR/scripts/AutoLaunch"
AUTOLAUNCH_TARGET_DIR="$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch"
PROFILE_NAME="Hermes Nerd Font"
PROFILE_GUID="7D5C40F6-8B4E-4E8F-9C61-1E4B4A6B1D3F"
PREFS_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

mkdir -p "$TARGET_DIR"

for profile in "$SOURCE_DIR"/*.json; do
  [ -e "$profile" ] || continue
  cp "$profile" "$TARGET_DIR/$(basename "$profile")"
  echo "Installed iTerm2 dynamic profile: $(basename "$profile")"
done

# iTerm2's official workaround for making a Dynamic Profile the default is an
# AutoLaunch Python API script, because dynamic profiles cannot ordinarily be
# made default from the Settings UI. It runs after dynamic profiles load.
mkdir -p "$AUTOLAUNCH_TARGET_DIR"
for script in "$AUTOLAUNCH_SOURCE_DIR"/*.py; do
  [ -e "$script" ] || continue
  cp "$script" "$AUTOLAUNCH_TARGET_DIR/$(basename "$script")"
  chmod +x "$AUTOLAUNCH_TARGET_DIR/$(basename "$script")"
  echo "Installed iTerm2 AutoLaunch script: $(basename "$script")"
done

# Also set the plist default GUID as a best-effort immediate/persistent hint.
# iTerm2 may overwrite plist edits while running, but the AutoLaunch script above
# is the reliable startup path.
if [ -f "$PREFS_PLIST" ]; then
  python3 - "$PREFS_PLIST" "$PROFILE_GUID" <<'PY'
import datetime
import pathlib
import plistlib
import shutil
import sys

prefs = pathlib.Path(sys.argv[1])
default_guid = sys.argv[2]
backup = prefs.with_name(prefs.name + ".backup." + datetime.datetime.now().strftime("%Y%m%d%H%M%S"))
shutil.copy2(prefs, backup)

with prefs.open("rb") as f:
    data = plistlib.load(f)

previous = data.get("Default Bookmark Guid")
data["Default Bookmark Guid"] = default_guid

with prefs.open("wb") as f:
    plistlib.dump(data, f)

print(f"Backed up iTerm2 preferences to {backup}")
print(f"Set iTerm2 default profile GUID hint: {previous!r} -> {default_guid!r}")
PY
  killall cfprefsd 2>/dev/null || true
else
  echo "iTerm2 preferences not found yet; dynamic profile was installed but plist default was not changed."
fi

echo "iTerm2 dynamic profiles installed. '$PROFILE_NAME' will be made default by AutoLaunch after iTerm2 restarts."
