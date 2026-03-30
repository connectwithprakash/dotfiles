#!/usr/bin/env bash
# Universal Dotfiles Installer
#
# Usage:
#   One-liner:  sh -c "$(curl -fsSL https://raw.githubusercontent.com/connectwithprakash/dotfiles/main/install.sh)"
#   Auto:       sh -c "$(curl -fsSL ...)" -- --auto
#   Components: sh -c "$(curl -fsSL ...)" -- --components zsh,neovim

set -e

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/connectwithprakash/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BRANCH="${DOTFILES_BRANCH:-main}"

# Minimal colors (lib.sh not available yet)
BOLD='\033[1m' DIM='\033[2m' GREEN='\033[0;32m' BLUE='\033[0;34m'
YELLOW='\033[1;33m' RED='\033[0;31m' CYAN='\033[0;36m' MAGENTA='\033[0;35m' NC='\033[0m'

print_success() { echo -e "  ${GREEN}✓${NC} $1"; }
print_error()   { echo -e "  ${RED}✗${NC} $1"; }
print_info()    { echo -e "  ${CYAN}→${NC} $1"; }
print_warning() { echo -e "  ${YELLOW}!${NC} $1"; }

# Parse arguments
AUTO_INSTALL=false
COMPONENTS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --auto|-a) AUTO_INSTALL=true; shift ;;
    --components|-c) COMPONENTS="$2"; shift 2 ;;
    --help|-h)
      echo "Dotfiles Installer"
      echo ""
      echo "Usage: install.sh [options]"
      echo ""
      echo "  -a, --auto           Install everything without prompts"
      echo "  -c, --components     Install specific components (comma-separated)"
      echo "                       Options: zsh, neovim, vscode, claude, system, pipx"
      echo "  -h, --help           Show this help"
      exit 0
      ;;
    *) shift ;;
  esac
done

# Banner
echo ""
echo -e "${MAGENTA}${BOLD}"
cat << 'EOF'
     ·  Dotfiles  ·
EOF
echo -e "${NC}"
echo -e "  ${DIM}Development environment setup${NC}"
echo ""

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is not installed."
  print_info "macOS: xcode-select --install"
  print_info "Linux: sudo apt install git"
  exit 1
fi
print_success "Git is installed"

# Clone or update repository
if [ -d "$DOTFILES_DIR" ]; then
  print_info "Updating existing dotfiles at $DOTFILES_DIR..."
  cd "$DOTFILES_DIR"
  git pull origin "$BRANCH" 2>/dev/null || print_warning "Could not pull latest changes"
  print_success "Repository updated"
else
  print_info "Cloning dotfiles to $DOTFILES_DIR..."
  git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
  cd "$DOTFILES_DIR"
  print_success "Repository cloned"
fi

# Make scripts executable
chmod +x bootstrap.sh update_dotfiles.sh dotfiles .claude/install.sh \
  scripts/*.sh zsh/*.sh neovim/*.sh vscode/*.sh 2>/dev/null || true
print_success "Scripts ready"

# Run bootstrap
echo ""
if [ "$AUTO_INSTALL" = true ]; then
  print_info "Running automated installation..."
  ./bootstrap.sh --force
elif [ -n "$COMPONENTS" ]; then
  print_info "Installing components: $COMPONENTS"
  IFS=',' read -ra COMP_ARRAY <<< "$COMPONENTS"
  for component in "${COMP_ARRAY[@]}"; do
    case "$component" in
      zsh)        ./zsh/install.sh ;;
      neovim|nvim) ./neovim/install.sh ;;
      vscode|code) ./vscode/install.sh ;;
      claude)     ./.claude/install.sh --force ;;
      system|deps) ./scripts/install_system_dependencies.sh ;;
      pipx|python) ./scripts/install_pipx_dependencies.sh ;;
      *) print_warning "Unknown component: $component" ;;
    esac
  done
else
  print_info "Launching interactive installer..."
  ./bootstrap.sh
fi

echo ""
print_success "Installation complete"
print_info "Location: $DOTFILES_DIR"
print_info "Restart your terminal or run: ${BOLD}source ~/.zshrc${NC}"
echo ""
