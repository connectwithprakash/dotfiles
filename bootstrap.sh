#!/usr/bin/env bash

# Don't use set -e — we handle failures per-step in run_step()
cd "$(dirname "${BASH_SOURCE[0]}")"
DOTFILES_DIR="$(pwd)"
source "$DOTFILES_DIR/scripts/lib.sh"

# Ensure Homebrew is in PATH for this session and all child scripts
ensure_brew_in_path
export PATH

# ── Git identity ─────────────────────────────────────────────────────────────

configure_git_identity() {
  local gitconfig="$DOTFILES_DIR/.gitconfig"
  local current_name current_email
  current_name=$(git config -f "$gitconfig" user.name 2>/dev/null || echo "")
  current_email=$(git config -f "$gitconfig" user.email 2>/dev/null || echo "")

  if [ -z "$current_name" ] || [ -z "$current_email" ]; then
    echo ""
    echo -e "${BOLD}Git Identity${NC}"
    echo -e "${DIM}Your name and email will be used for git commits.${NC}"
    echo ""
  fi

  if [ -z "$current_name" ]; then
    if [ "$HAS_GUM" = true ]; then
      current_name=$(gum input --placeholder "Your Name" --header "Git user name")
    else
      read -p "  Git user name: " current_name
    fi
    [ -n "$current_name" ] && git config -f "$gitconfig" user.name "$current_name"
  fi

  if [ -z "$current_email" ]; then
    if [ "$HAS_GUM" = true ]; then
      current_email=$(gum input --placeholder "you@example.com" --header "Git email")
    else
      read -p "  Git email: " current_email
    fi
    [ -n "$current_email" ] && git config -f "$gitconfig" user.email "$current_email"
  fi
}

# ── Sync dotfiles ────────────────────────────────────────────────────────────

syncDotfiles() {
  rsync_output=$(rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "CLAUDE.md" \
    --exclude ".claude/" \
    --exclude "scripts/" \
    --exclude "zsh/" \
    --exclude "neovim/" \
    --exclude "vscode/" \
    --exclude "install.sh" \
    --exclude "update_dotfiles.sh" \
    --exclude "dotfiles" \
    --exclude "Makefile" \
    --exclude "LICENSE" \
    --exclude ".github/" \
    -avh --no-perms . ~ 2>/dev/null) || true

  if [ -n "$rsync_output" ]; then
    source ~/.bash_profile 2>/dev/null || true
  fi
}

# ── Component definitions ────────────────────────────────────────────────────

COMPONENTS=(
  "System Dependencies"
  "Python (pyenv + uv)"
  "Dotfiles Sync"
  "Zsh + Starship"
  "Neovim"
  "VS Code"
  "Claude Code"
)

# macOS-only component
if [ "$(uname -s)" = "Darwin" ]; then
  COMPONENTS+=("macOS Preferences")
fi

# Map component name to function
run_component_by_name() {
  local name="$1"
  case "$name" in
    "System Dependencies")  run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/scripts/install_system_dependencies.sh" ;;
    "Python (pyenv + uv)")  run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/scripts/install_python_tools.sh" ;;
    "Dotfiles Sync")        print_step "$STEP" "$TOTAL" "$name"; syncDotfiles; print_success "Done" ;;
    "Zsh + Starship")       run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/zsh/install.sh" ;;
    "Neovim")               run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/neovim/install.sh" ;;
    "VS Code")              run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/vscode/install.sh" ;;
    "Claude Code")          run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/.claude/install.sh" "--force" ;;
    "macOS Preferences")    run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/scripts/macos.sh" ;;
  esac
}

# ── Main ─────────────────────────────────────────────────────────────────────

print_banner "Dotfiles" "Development environment setup"

# Update from remote
git pull origin main 2>/dev/null || print_warning "Could not pull from remote"

# Configure git identity
configure_git_identity

TOTAL_START=$(date +%s)

if [[ "$1" == "--force" || "$1" == "-f" ]]; then
  # Force mode: install everything
  selected=("${COMPONENTS[@]}")
  echo ""
  print_info "Force mode: installing all components"
else
  # Interactive mode: let user pick
  select_components "Select components to install:" "${COMPONENTS[@]}"
  selected=("${SELECTED_COMPONENTS[@]}")

  if [ ${#selected[@]} -eq 0 ]; then
    echo ""
    print_warning "No components selected. Nothing to do."
    exit 0
  fi
fi

# Run selected components
TOTAL=${#selected[@]}
STEP=0
succeeded=()
failed=()
skipped=()

for comp in "${selected[@]}"; do
  ((STEP++))
  if run_component_by_name "$comp"; then
    succeeded+=("$comp")
  else
    failed+=("$comp")
  fi
done

# Mark unselected as skipped
for comp in "${COMPONENTS[@]}"; do
  local_found=false
  for sel in "${selected[@]}"; do
    [[ "$comp" == "$sel" ]] && local_found=true && break
  done
  [[ "$local_found" == false ]] && skipped+=("$comp")
done

# ── Symlink `dotfiles` CLI onto PATH ─────────────────────────────────────────

link_dotfiles_cli() {
  local target="$DOTFILES_DIR/dotfiles"
  local link_dir="$HOME/.local/bin"
  local link_path="$link_dir/dotfiles"

  mkdir -p "$link_dir"
  if [ ! -L "$link_path" ] || [ "$(readlink "$link_path")" != "$target" ]; then
    ln -sf "$target" "$link_path"
    print_success "dotfiles CLI linked to $link_path"
  fi
}

link_dotfiles_cli

# ── Summary ──────────────────────────────────────────────────────────────────

TOTAL_ELAPSED=$(( $(date +%s) - TOTAL_START ))

echo ""
echo ""
if [ "$HAS_GUM" = true ]; then
  gum style \
    --border rounded \
    --border-foreground 99 \
    --padding "0 2" \
    --margin "0 0" \
    "Setup Complete (${TOTAL_ELAPSED}s)"
else
  echo -e "${BOLD}── Setup Complete (${TOTAL_ELAPSED}s) ──${NC}"
fi

echo ""
for comp in "${succeeded[@]}"; do
  print_success "$comp"
done
for comp in "${failed[@]}"; do
  print_error "$comp"
done
for comp in "${skipped[@]}"; do
  echo -e "  ${GRAY}– $comp (skipped)${NC}"
done

echo ""
if [ ${#failed[@]} -eq 0 ]; then
  print_info "Restart your terminal or run: ${BOLD}source ~/.zshrc${NC}"
else
  print_warning "${#failed[@]} component(s) had errors. Check output above."
fi
echo ""
