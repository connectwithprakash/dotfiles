#!/usr/bin/env bash

set -euo pipefail

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
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export PATH="$PYENV_ROOT/bin:$PATH"
if command_exists pyenv; then
  eval "$(pyenv init -)"
fi

latest_stable_python() {
  if pyenv latest -k 3 >/dev/null 2>&1; then
    pyenv latest -k 3
  else
    pyenv install --list 2>/dev/null \
      | grep -E '^\s+3\.[0-9]+\.[0-9]+$' \
      | grep -Ev '(a|b|rc|dev)' \
      | tail -1 \
      | tr -d ' '
  fi
}

# Install latest stable Python 3 if no pyenv versions are installed yet. Building
# CPython can fail on fresh macOS systems when Xcode CLT or formula deps are not
# ready, so report that clearly instead of making the whole bootstrap opaque.
if command_exists pyenv; then
  if [ -z "$(pyenv versions --bare 2>/dev/null)" ]; then
    echo "Installing latest stable Python via pyenv..."
    latest="$(latest_stable_python)"
    if [ -n "$latest" ]; then
      if pyenv install -s "$latest"; then
        pyenv global "$latest"
        echo "Python $latest installed and set as global."
      else
        echo "Warning: pyenv could not build Python $latest."
        echo "         System packages, uv, and ruff can still be installed."
        echo "         After installing Xcode Command Line Tools/dependencies, run: pyenv install $latest"
      fi
    else
      echo "Warning: could not determine latest stable Python version from pyenv."
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
    export PATH="$HOME/.local/bin:$PATH"
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
    if ! command_exists uv; then
      echo "Error: uv is required to install ruff without Homebrew."
      exit 1
    fi
    uv tool install ruff
  fi
else
  echo "ruff is already installed."
fi

# ── Global Python tools via uv ───────────────────────────────────────────────

if command_exists uv; then
  # uv tool install replaces pipx — isolated environments, faster installs.
  # Some machines already have these executables from pipx/Homebrew/a previous
  # partial uv install. In that case, do not overwrite them during bootstrap.
  UV_TOOLS=(
    "poetry"
    "ipython"
  )

  uv_bin_dir="$(uv tool dir --bin 2>/dev/null || echo "$HOME/.local/bin")"

  for tool in "${UV_TOOLS[@]}"; do
    if uv tool list 2>/dev/null | grep -q "^$tool "; then
      echo "$tool is already installed as a uv tool."
    elif command_exists "$tool"; then
      echo "$tool executable already exists at $(command -v "$tool"); skipping uv tool install."
    elif [ -x "$uv_bin_dir/$tool" ]; then
      echo "$tool executable already exists at $uv_bin_dir/$tool; skipping uv tool install."
    else
      echo "Installing $tool via uv..."
      uv tool install "$tool"
    fi
  done
else
  echo "Warning: uv is not available; skipping global Python tools."
fi

echo "Python toolchain setup complete!"
echo "  pyenv: $(pyenv --version 2>/dev/null || echo 'not found')"
echo "  uv:    $(uv --version 2>/dev/null || echo 'not found')"
echo "  ruff:  $(ruff --version 2>/dev/null || echo 'not found')"
