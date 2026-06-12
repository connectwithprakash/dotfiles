#!/usr/bin/env bash

# Don't use set -e — we handle failures per-step in run_step()
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
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
      read -rp "  Git user name: " current_name
    fi
    [ -n "$current_name" ] && git config -f "$gitconfig" user.name "$current_name"
  fi

  if [ -z "$current_email" ]; then
    if [ "$HAS_GUM" = true ]; then
      current_email=$(gum input --placeholder "you@example.com" --header "Git email")
    else
      read -rp "  Git email: " current_email
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
    # shellcheck source=/dev/null
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
  "iTerm2"
  "VS Code"
  "Claude Code"
)

# macOS-only component
if [ "$(uname -s)" = "Darwin" ]; then
  COMPONENTS+=("macOS Preferences")
fi

# macOS preferences require sudo and must run in a fresh terminal session
# Running sudo inside bootstrap kills open apps (Safari, Terminal) via TTY signals
_run_macos_prefs() {
  print_step "$STEP" "$TOTAL" "macOS Preferences"
  echo ""
  print_info "macOS preferences require sudo and must be run separately to avoid"
  print_info "closing open applications. Run this after bootstrap completes:"
  echo ""
  echo -e "    ${BOLD}./scripts/macos.sh${NC}"
  echo ""
  print_success "Reminder noted"
}

# Component aliases for non-interactive installs.
component_from_arg() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"

  case "$key" in
    system|systems|deps|dependencies|brew|homebrew) echo "System Dependencies" ;;
    python|pyenv|uv|pythonuv|pyenvuv) echo "Python (pyenv + uv)" ;;
    dotfiles|sync|dotfilessync) echo "Dotfiles Sync" ;;
    zsh|shell|starship|zshstarship|ohmyzsh|omz) echo "Zsh + Starship" ;;
    neovim|nvim|vim) echo "Neovim" ;;
    iterm|iterm2|terminal) echo "iTerm2" ;;
    vscode|code|visualstudiocode) echo "VS Code" ;;
    claude|claudecode) echo "Claude Code" ;;
    macos|osx|preferences|macospreferences) echo "macOS Preferences" ;;
    *) return 1 ;;
  esac
}

show_usage() {
  print_banner "Dotfiles" "Development environment setup"
  echo "Usage: ./bootstrap.sh [--force|-f] [--list] [--dry-run] [component ...]"
  echo ""
  echo "Components and aliases:"
  echo "  system | deps | brew       -> System Dependencies"
  echo "  python | pyenv | uv        -> Python (pyenv + uv)"
  echo "  sync | dotfiles            -> Dotfiles Sync"
  echo "  zsh | starship | shell     -> Zsh + Starship"
  echo "  neovim | nvim              -> Neovim"
  echo "  iterm2 | iterm | terminal  -> iTerm2"
  echo "  vscode | code              -> VS Code"
  echo "  claude | claude-code       -> Claude Code"
  echo "  macos | preferences        -> macOS Preferences"
  echo ""
  echo "Examples:"
  echo "  ./bootstrap.sh zsh"
  echo "  ./bootstrap.sh starship"
  echo "  ./bootstrap.sh sync zsh iterm2"
  echo "  ./bootstrap.sh --dry-run zsh"
}

list_components() {
  local comp
  for comp in "${COMPONENTS[@]}"; do
    echo "$comp"
  done
}

select_components_from_args() {
  SELECTED_COMPONENTS=()
  local arg comp existing duplicate

  for arg in "$@"; do
    comp="$(component_from_arg "$arg")" || {
      print_error "Unknown component: $arg"
      echo ""
      show_usage
      return 1
    }

    duplicate=false
    for existing in "${SELECTED_COMPONENTS[@]}"; do
      [ "$existing" = "$comp" ] && duplicate=true && break
    done
    [ "$duplicate" = false ] && SELECTED_COMPONENTS+=("$comp")
  done
}

# Map component name to function
run_component_by_name() {
  local name="$1"
  case "$name" in
    "System Dependencies")  run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/scripts/install_system_dependencies.sh" ;;
    "Python (pyenv + uv)")  run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/scripts/install_python_tools.sh" ;;
    "Dotfiles Sync")        print_step "$STEP" "$TOTAL" "$name"; syncDotfiles; print_success "Done" ;;
    "Zsh + Starship")       run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/zsh/install.sh" ;;
    "Neovim")               run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/neovim/install.sh" ;;
    "iTerm2")               run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/iterm2/install.sh" ;;
    "VS Code")              run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/vscode/install.sh" ;;
    "Claude Code")          run_step "$STEP" "$TOTAL" "$name" "$DOTFILES_DIR/.claude/install.sh" "--force" ;;
    "macOS Preferences")    _run_macos_prefs ;;
  esac
}

# ── Main ─────────────────────────────────────────────────────────────────────

DRY_RUN=false
FORCE=false
component_args=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force|-f)
      FORCE=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --list)
      list_components
      exit 0
      ;;
    --help|-h)
      show_usage
      exit 0
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        component_args+=("$1")
        shift
      done
      break
      ;;
    --*)
      print_error "Unknown option: $1"
      echo ""
      show_usage
      exit 1
      ;;
    *)
      component_args+=("$1")
      ;;
  esac
  shift
done

print_banner "Dotfiles" "Development environment setup"

# Update from remote
git pull origin main 2>/dev/null || print_warning "Could not pull from remote"

# Configure git identity
configure_git_identity

TOTAL_START=$(date +%s)

if [ "$FORCE" = true ]; then
  # Force mode: install everything
  selected=("${COMPONENTS[@]}")
  echo ""
  print_info "Force mode: installing all components"
elif [ ${#component_args[@]} -gt 0 ]; then
  select_components_from_args "${component_args[@]}" || exit 1
  selected=("${SELECTED_COMPONENTS[@]}")
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

if [ "$DRY_RUN" = true ]; then
  echo ""
  print_info "Dry run: selected component(s):"
  for comp in "${selected[@]}"; do
    echo "  - $comp"
  done
  exit 0
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
