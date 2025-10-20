#!/usr/bin/env bash
# Universal Dotfiles Installer
#
# Usage:
#   One-liner:  sh -c "$(curl -fsSL https://raw.githubusercontent.com/connectwithprakash/dotfiles/main/install.sh)"
#   Interactive: sh -c "$(curl -fsSL https://raw.githubusercontent.com/connectwithprakash/dotfiles/main/install.sh)" -- --interactive
#   Auto:        sh -c "$(curl -fsSL https://raw.githubusercontent.com/connectwithprakash/dotfiles/main/install.sh)" -- --auto
#   Components:  sh -c "$(curl -fsSL https://raw.githubusercontent.com/connectwithprakash/dotfiles/main/install.sh)" -- --components zsh,neovim

set -e

# Configuration
REPO_URL="${DOTFILES_REPO_URL:-https://github.com/connectwithprakash/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BRANCH="${DOTFILES_BRANCH:-main}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
INTERACTIVE=false
AUTO_INSTALL=false
COMPONENTS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --interactive|-i) INTERACTIVE=true; shift ;;
    --auto|-a) AUTO_INSTALL=true; shift ;;
    --components|-c) COMPONENTS="$2"; shift 2 ;;
    --help|-h)
      echo "Dotfiles Installer"
      echo ""
      echo "Usage:"
      echo "  install.sh [options]"
      echo ""
      echo "Options:"
      echo "  -i, --interactive    Launch interactive TUI installer"
      echo "  -a, --auto           Auto-install everything without prompts"
      echo "  -c, --components     Install specific components (comma-separated)"
      echo "  -h, --help           Show this help message"
      echo ""
      echo "Examples:"
      echo "  install.sh --interactive"
      echo "  install.sh --auto"
      echo "  install.sh --components zsh,neovim,claude"
      exit 0
      ;;
    *) shift ;;
  esac
done

# Helper functions
print_header() {
  echo ""
  echo -e "${BLUE}╭─────────────────────────────────────────────────────╮${NC}"
  echo -e "${BLUE}│${NC}  $1"
  echo -e "${BLUE}╰─────────────────────────────────────────────────────╯${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

# Welcome banner
clear
echo -e "${PURPLE}"
cat << "EOF"
    ____        __  _____ __
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/

EOF
echo -e "${NC}"
print_header "Prakash's Development Environment Setup"

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is not installed. Please install git first."
  print_info "macOS: xcode-select --install"
  print_info "Linux: sudo apt install git"
  exit 1
fi

print_success "Git is installed"

# Clone or update repository
if [ -d "$DOTFILES_DIR" ]; then
  print_info "Dotfiles directory already exists at: $DOTFILES_DIR"
  print_info "Updating from remote..."
  cd "$DOTFILES_DIR"
  git pull origin "$BRANCH" || print_warning "Failed to pull latest changes"
  print_success "Repository updated"
else
  print_info "Cloning dotfiles repository..."
  git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
  cd "$DOTFILES_DIR"
  print_success "Repository cloned to $DOTFILES_DIR"
fi

# Make scripts executable
chmod +x bootstrap.sh 2>/dev/null || true
chmod +x update_dotfiles.sh 2>/dev/null || true
chmod +x .claude/install.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x zsh/*.sh 2>/dev/null || true
chmod +x neovim/*.sh 2>/dev/null || true
chmod +x vscode/*.sh 2>/dev/null || true

print_success "Scripts made executable"

# Determine installation mode
if [ "$AUTO_INSTALL" = true ]; then
  print_header "Running automated installation..."
  ./bootstrap.sh --force
elif [ "$INTERACTIVE" = true ]; then
  print_header "Launching interactive installer..."
  ./bootstrap.sh
elif [ -n "$COMPONENTS" ]; then
  print_header "Installing selected components: $COMPONENTS"
  # Parse components and install selectively
  IFS=',' read -ra COMP_ARRAY <<< "$COMPONENTS"
  for component in "${COMP_ARRAY[@]}"; do
    case "$component" in
      zsh)
        print_info "Installing Zsh configuration..."
        ./zsh/install.sh || print_warning "Zsh installation had issues"
        ;;
      neovim|nvim)
        print_info "Installing Neovim..."
        ./neovim/install.sh || print_warning "Neovim installation had issues"
        ;;
      vscode|code)
        print_info "Installing VS Code..."
        ./vscode/install.sh || print_warning "VS Code installation had issues"
        ;;
      claude)
        print_info "Installing Claude Code configurations..."
        ./.claude/install.sh --force || print_warning "Claude installation had issues"
        ;;
      system|deps|dependencies)
        print_info "Installing system dependencies..."
        ./scripts/install_system_dependencies.sh || print_warning "System dependencies installation had issues"
        ;;
      pipx|python)
        print_info "Installing Python/pipx dependencies..."
        ./scripts/install_pipx_dependencies.sh || print_warning "Pipx dependencies installation had issues"
        ;;
      *)
        print_warning "Unknown component: $component"
        ;;
    esac
  done
else
  # Default: Interactive mode
  print_header "Launching interactive installer..."
  ./bootstrap.sh
fi

# Success message
echo ""
print_header "Installation Complete!"
print_success "Dotfiles installed successfully"
print_info "Location: $DOTFILES_DIR"
echo ""
print_info "Next steps:"
echo -e "  ${CYAN}→${NC} Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
echo -e "  ${CYAN}→${NC} Manage dotfiles: ${YELLOW}cd $DOTFILES_DIR${NC}"
echo -e "  ${CYAN}→${NC} Sync changes: ${YELLOW}./update_dotfiles.sh${NC}"
echo ""
print_success "Happy coding! 🚀"
echo ""
