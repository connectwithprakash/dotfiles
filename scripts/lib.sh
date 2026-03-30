#!/usr/bin/env bash
# Shared utility functions for dotfiles scripts

# Colors (only set if stdout is a terminal)
if [ -t 1 ]; then
  BOLD='\033[1m'
  DIM='\033[2m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  GRAY='\033[0;90m'
  MAGENTA='\033[0;35m'
  NC='\033[0m'
else
  BOLD='' DIM='' GREEN='' BLUE='' YELLOW='' RED='' CYAN='' GRAY='' MAGENTA='' NC=''
fi

# Check if gum is available
HAS_GUM=false
if command -v gum &> /dev/null; then
  HAS_GUM=true
fi

# Print helpers
print_success() { echo -e "  ${GREEN}✓${NC} $1"; }
print_error()   { echo -e "  ${RED}✗${NC} $1"; }
print_info()    { echo -e "  ${CYAN}→${NC} $1"; }
print_warning() { echo -e "  ${YELLOW}!${NC} $1"; }
print_step()    { echo -e "\n${BOLD}${BLUE}[$1/$2]${NC} ${BOLD}$3${NC}"; }

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Prompt user with yes/no question (uses gum if available)
prompt_yes_no() {
  if [ "$HAS_GUM" = true ]; then
    gum confirm "$1"
    return $?
  else
    while true; do
      read -p "$1 (y/n): " yn
      case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no.";;
      esac
    done
  fi
}

# Backup a file before overwriting it
backup_file() {
  local file="$1"
  [ ! -f "$file" ] && return 0

  local backup_dir="$HOME/.dotfiles-backup/$(date +%Y-%m-%d_%H%M%S)"
  local relative_path="${file#$HOME/}"
  local backup_path="$backup_dir/$relative_path"

  mkdir -p "$(dirname "$backup_path")"
  cp "$file" "$backup_path"
}

# Detect Homebrew prefix portably
get_brew_prefix() {
  if [ -f /opt/homebrew/bin/brew ]; then
    echo "/opt/homebrew"
  elif [ -f /usr/local/bin/brew ]; then
    echo "/usr/local"
  else
    echo ""
  fi
}

# Ensure Homebrew is in PATH
ensure_brew_in_path() {
  local prefix
  prefix="$(get_brew_prefix)"
  if [ -n "$prefix" ] && [ -f "$prefix/bin/brew" ]; then
    eval "$("$prefix/bin/brew" shellenv)"
  fi
}

# Run a component with timing and status
run_step() {
  local step_num="$1"
  local total="$2"
  local label="$3"
  local script="$4"

  print_step "$step_num" "$total" "$label"

  if [ ! -f "$script" ] || [ ! -x "$script" ]; then
    print_warning "Script not found: $script"
    return 0
  fi

  local start_time
  start_time=$(date +%s)

  if "$script"; then
    local elapsed=$(( $(date +%s) - start_time ))
    print_success "Done (${elapsed}s)"
    return 0
  else
    print_error "Failed"
    return 1
  fi
}

# Print a banner
print_banner() {
  echo ""
  if [ "$HAS_GUM" = true ]; then
    gum style \
      --border double \
      --border-foreground 99 \
      --padding "1 3" \
      --margin "0 0" \
      --bold \
      "$1" "" "$2"
  else
    echo -e "${BOLD}${MAGENTA}"
    echo "  ╔══════════════════════════════════════════╗"
    printf "  ║  %-40s║\n" "$1"
    printf "  ║  ${DIM}%-40s${BOLD}${MAGENTA}║\n" "$2"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${NC}"
  fi
}

# Multi-select components (uses gum if available, otherwise numbered menu)
# Usage: select_components "prompt" component1 component2 ...
# Sets SELECTED_COMPONENTS array with chosen items
select_components() {
  local prompt="$1"
  shift
  local components=("$@")
  SELECTED_COMPONENTS=()

  if [ "$HAS_GUM" = true ]; then
    local selected
    selected=$(printf '%s\n' "${components[@]}" | gum choose --no-limit --height 15 --header "$prompt")
    while IFS= read -r line; do
      [ -n "$line" ] && SELECTED_COMPONENTS+=("$line")
    done <<< "$selected"
  else
    echo ""
    echo -e "${BOLD}$prompt${NC}"
    echo -e "${DIM}(space-separated numbers, or 'a' for all, 'n' for none)${NC}"
    echo ""
    local i=1
    for comp in "${components[@]}"; do
      echo -e "  ${CYAN}$i)${NC} $comp"
      ((i++))
    done
    echo ""
    read -p "Selection: " selection

    if [[ "$selection" == "a" || "$selection" == "A" ]]; then
      SELECTED_COMPONENTS=("${components[@]}")
    elif [[ "$selection" == "n" || "$selection" == "N" || -z "$selection" ]]; then
      SELECTED_COMPONENTS=()
    else
      for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#components[@]} )); then
          SELECTED_COMPONENTS+=("${components[$((num-1))]}")
        fi
      done
    fi
  fi
}
