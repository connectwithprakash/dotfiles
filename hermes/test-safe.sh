#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_HERMES_DIR="$SCRIPT_DIR"
HERMES_DIR="$HOME/.hermes"
CONFIG_YAML="$HERMES_DIR/config.yaml"
SKILL_SRC="$DOTFILES_HERMES_DIR/skills/devops/hermes-agent-dotfiles"
SKILL_DST="$HERMES_DIR/skills/devops/hermes-agent-dotfiles"

fail() {
  echo "Error: $*" >&2
  exit 1
}

echo "Running tests for Hermes dotfiles setup..."

command -v hermes >/dev/null 2>&1 || fail "Hermes is not installed or not on PATH."
echo "Hermes is installed."

[ -f "$CONFIG_YAML" ] || fail "Live Hermes config is missing: $CONFIG_YAML"
echo "Live Hermes config exists."

if [ -L "$CONFIG_YAML" ]; then
  echo "Live Hermes config is symlinked to: $(readlink "$CONFIG_YAML")"
else
  echo "Live Hermes config is not symlinked; this is the safe default."
fi

if [ -d "$SKILL_SRC" ]; then
  [ -L "$SKILL_DST" ] || fail "Managed skill is present in repo but not linked at $SKILL_DST. Run ./hermes/install.sh."
  echo "Managed skill symlink exists: $SKILL_DST -> $(readlink "$SKILL_DST")"
else
  echo "No managed Hermes skill in repo; skipping skill link check."
fi

hermes --help >/dev/null 2>&1 || fail "Hermes command is not working."

echo "Hermes dotfiles tests passed."
