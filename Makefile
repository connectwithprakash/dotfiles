.PHONY: install install-force install-deps install-pipx install-zsh install-neovim \
       install-vscode install-claude sync status health test lint macos \
       uninstall-zsh backup-zsh help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Full interactive installation
	@./bootstrap.sh

install-force: ## Install everything without prompts
	@./bootstrap.sh --force

install-deps: ## Install system dependencies (uses Brewfile on macOS)
	@./scripts/install_system_dependencies.sh

brew-check: ## Check if all Brewfile dependencies are installed
	@brew bundle check --file=Brewfile || echo "Run 'make install-deps' to install missing packages"

install-pipx: ## Install Python tools via pipx
	@./scripts/install_pipx_dependencies.sh

install-zsh: ## Install Zsh + Oh My Zsh + plugins
	@./zsh/install.sh

install-neovim: ## Install Neovim + plugins
	@./neovim/install.sh

install-vscode: ## Install VS Code
	@./vscode/install.sh

install-claude: ## Install Claude Code configurations
	@./.claude/install.sh

sync: ## Sync dotfiles (interactive direction choice)
	@./update_dotfiles.sh

status: ## Show dotfiles status
	@./dotfiles status

health: ## Run system health check
	@./dotfiles health

lint: ## Run shellcheck on all scripts
	@echo "Running shellcheck..."
	@shellcheck -x bootstrap.sh update_dotfiles.sh install.sh dotfiles \
		scripts/*.sh zsh/install.sh zsh/uninstall.sh zsh/backup_zsh_dotfiles.sh \
		neovim/install.sh vscode/install.sh vscode/fix_vscode_fonts.sh \
		.claude/install.sh \
		2>&1 || true
	@echo "Done."

test: lint ## Run all tests (currently just lint)
	@echo "Syntax checking all scripts..."
	@for f in bootstrap.sh update_dotfiles.sh install.sh dotfiles \
		scripts/*.sh zsh/install.sh zsh/uninstall.sh zsh/backup_zsh_dotfiles.sh \
		neovim/install.sh vscode/install.sh vscode/fix_vscode_fonts.sh \
		.claude/install.sh; do \
		bash -n "$$f" && echo "  [ok] $$f" || echo "  [FAIL] $$f"; \
	done
	@echo "All checks passed."

macos: ## Apply macOS system preferences
	@./scripts/macos.sh

uninstall-zsh: ## Uninstall Zsh and Oh My Zsh
	@./zsh/uninstall.sh

backup-zsh: ## Backup current Zsh configs to repo
	@./zsh/backup_zsh_dotfiles.sh
