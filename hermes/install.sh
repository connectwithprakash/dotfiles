#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_HERMES_DIR="$SCRIPT_DIR"
HERMES_DIR="$HOME/.hermes"
SKILL_SRC="$DOTFILES_HERMES_DIR/skills/devops/hermes-agent-dotfiles"
SKILL_DST="$HERMES_DIR/skills/devops/hermes-agent-dotfiles"
CONFIG_SRC="$DOTFILES_HERMES_DIR/config.yaml"
CONFIG_DST="$HERMES_DIR/config.yaml"
LINK_CONFIG=false

usage() {
  cat <<'EOF'
Usage: hermes/install.sh [--link-config]

Safely installs Hermes dotfiles-managed assets.

Default behavior:
  - Requires Hermes to already be installed.
  - Links the managed dotfiles skill into ~/.hermes/skills/ when present.
  - Leaves ~/.hermes/config.yaml untouched.

Optional:
  --link-config   Replace ~/.hermes/config.yaml with a symlink to the repo copy.
                  The existing config is backed up first. Use only after manually
                  verifying the repo config contains no secrets and is current.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --link-config) LINK_CONFIG=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if ! command -v hermes >/dev/null 2>&1; then
  echo "Error: hermes is not installed or not on PATH." >&2
  echo "Install Hermes first, then rerun this script." >&2
  echo "Official install: curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash" >&2
  exit 1
fi

mkdir -p "$HERMES_DIR/skills/devops"

if [ -d "$SKILL_SRC" ]; then
  if [ -e "$SKILL_DST" ] && [ ! -L "$SKILL_DST" ]; then
    backup="$SKILL_DST.backup.$(date +%Y%m%d%H%M%S)"
    mv "$SKILL_DST" "$backup"
    echo "Backed up existing skill directory to $backup"
  fi
  ln -sfn "$SKILL_SRC" "$SKILL_DST"
  echo "Linked skill: $SKILL_DST -> $SKILL_SRC"
else
  echo "Warning: custom skill not found at $SKILL_SRC; skipping skill symlink" >&2
fi

if [ "$LINK_CONFIG" = true ]; then
  if [ ! -f "$CONFIG_SRC" ]; then
    echo "Error: missing dotfiles config at $CONFIG_SRC" >&2
    exit 1
  fi

  if [ -e "$CONFIG_DST" ] && [ ! -L "$CONFIG_DST" ]; then
    backup="$CONFIG_DST.backup.$(date +%Y%m%d%H%M%S)"
    cp "$CONFIG_DST" "$backup"
    echo "Backed up existing config to $backup"
  fi

  ln -sfn "$CONFIG_SRC" "$CONFIG_DST"
  echo "Linked config: $CONFIG_DST -> $CONFIG_SRC"
else
  echo "Left live config untouched: $CONFIG_DST"
  echo "To link it intentionally after review, rerun: $0 --link-config"
fi

hermes --help >/dev/null

echo "Hermes dotfiles check completed successfully."
