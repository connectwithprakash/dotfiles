#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/lib.sh
if ! source "$SCRIPT_DIR/../scripts/lib.sh" 2>/dev/null; then
  command_exists() { command -v "$1" >/dev/null 2>&1; }
fi

HERMES_HOME="$HOME/.hermes"
HERMES_REPO="$HERMES_HOME/hermes-agent"

# Install Hermes Agent
install_hermes() {
  if [ -d "$HERMES_REPO" ]; then
    echo "Hermes Agent already installed, updating..."
    cd "$HERMES_REPO"
    git pull --ff-only origin main || true
  else
    echo "Installing Hermes Agent..."
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
    return
  fi
}

# Install extra Python packages not bundled with Hermes
install_extra_deps() {
  local venv_python="$HERMES_REPO/venv/bin/python"

  if [ ! -f "$venv_python" ]; then
    echo "Hermes venv not found at $venv_python. Run the Hermes installer first."
    return 1
  fi

  echo "Installing extra dependencies into Hermes venv..."

  if ! command_exists uv; then
    echo "uv not found. Install it first: brew install uv"
    return 1
  fi

  # Telegram gateway
  uv pip install "python-telegram-bot[job-queue]" --python "$venv_python"

  # Cron scheduling
  uv pip install croniter --python "$venv_python"

  # Local TTS (NeuTTS)
  uv pip install -U "neutts[all]" --python "$venv_python"

  # Voice mode audio
  uv pip install sounddevice numpy --python "$venv_python"

  echo "Extra dependencies installed!"
}

# Install gateway as launchd service
install_gateway_service() {
  if command_exists hermes; then
    echo "Installing Hermes gateway service..."
    hermes gateway install 2>/dev/null || hermes gateway restart 2>/dev/null || true
    echo "Gateway service installed!"
  else
    echo "hermes command not found. Ensure ~/.local/bin is on PATH."
  fi
}

# Main
echo "=== Hermes Agent Setup ==="
install_hermes
install_extra_deps
install_gateway_service
echo ""
echo "Hermes Agent setup complete!"
echo "  Config:  ~/.hermes/.env (add API keys)"
echo "  Settings: ~/.hermes/config.yaml"
echo "  Test:    hermes doctor"
