#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf '%s\n' 'Obsidian vault backup requires macOS launchd.' >&2
  exit 1
fi

AUTOMATION_ROOT="${AGENT_SKILLS_DIR:-$HOME/Developer/agent-skills}/automations/obsidian-vault-backup"
VAULT_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/bodhi"
INSTALLER="$AUTOMATION_ROOT/install.sh"

if [[ ! -x "$INSTALLER" ]]; then
  printf 'Missing canonical installer: %s\n' "$INSTALLER" >&2
  printf '%s\n' 'Clone or update ~/Developer/agent-skills first.' >&2
  exit 1
fi

if [[ ! -d "$VAULT_PATH" ]]; then
  printf 'Obsidian vault not found: %s\n' "$VAULT_PATH" >&2
  exit 1
fi

printf '%s\n' 'Delegating to the canonical Obsidian backup automation.'
printf '%s\n' 'The Full Disk Access prerequisite for /usr/bin/python3 must be granted separately.'
exec "$INSTALLER"
