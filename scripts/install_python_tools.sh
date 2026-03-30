#!/usr/bin/env bash

set -e

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure Homebrew is available
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── pyenv ────────────────────────────────────────────────────────────────────

if ! command_exists pyenv; then
  echo "Installing pyenv..."
  if command_exists brew; then
    brew install pyenv
  else
    curl -fsSL https://pyenv.run | bash
  fi
else
  echo "pyenv is already installed."
fi

# Initialize pyenv for this session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command_exists pyenv; then
  eval "$(pyenv init -)"
fi

# Install latest Python 3 if no versions installed yet
if command_exists pyenv; then
  if [ -z "$(pyenv versions --bare 2>/dev/null)" ]; then
    echo "Installing latest Python via pyenv..."
    latest=$(pyenv install --list 2>/dev/null | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
    if [ -n "$latest" ]; then
      pyenv install "$latest"
      pyenv global "$latest"
      echo "Python $latest installed and set as global."
    fi
  else
    echo "pyenv Python versions already installed."
  fi
fi

# ── uv ───────────────────────────────────────────────────────────────────────

if ! command_exists uv; then
  echo "Installing uv..."
  if command_exists brew; then
    brew install uv
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
else
  echo "uv is already installed."
fi

# ── ruff ─────────────────────────────────────────────────────────────────────

if ! command_exists ruff; then
  echo "Installing ruff..."
  if command_exists brew; then
    brew install ruff
  else
    uv tool install ruff
  fi
else
  echo "ruff is already installed."
fi

# ── Global Python tools via uv ───────────────────────────────────────────────

# uv tool install replaces pipx — isolated environments, faster installs
UV_TOOLS=(
  "poetry"
  "ipython"
)

for tool in "${UV_TOOLS[@]}"; do
  if ! uv tool list 2>/dev/null | grep -q "^$tool "; then
    echo "Installing $tool via uv..."
    uv tool install "$tool"
  else
    echo "$tool is already installed."
  fi
done

echo "Python toolchain setup complete!"
echo "  pyenv: $(pyenv --version 2>/dev/null || echo 'not found')"
echo "  uv:    $(uv --version 2>/dev/null || echo 'not found')"
echo "  ruff:  $(ruff --version 2>/dev/null || echo 'not found')"
