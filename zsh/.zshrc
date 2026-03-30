# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Starship handles the prompt

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
)

source "$ZSH/oh-my-zsh.sh"

# Homebrew (detect architecture)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# Source dotfiles
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.exports ]] && source ~/.exports
[[ -f ~/.functions ]] && source ~/.functions

# fzf integration
if (( $+commands[fzf] )); then
  source <(fzf --zsh 2>/dev/null) || true
fi

# zoxide (smarter cd)
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# History substring search keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# VIMRUNTIME
if (( $+commands[nvim] )); then
  _brew_prefix="$(brew --prefix 2>/dev/null || echo "")"
  _vimruntime_path="$_brew_prefix/share/nvim/runtime"
  if [[ ! -d "$_vimruntime_path" ]] && [[ -n "$_brew_prefix" ]]; then
    _nvim_version=$(nvim --version 2>/dev/null | head -n 1 | awk '{print $2}' | sed 's/^v//')
    _vimruntime_path="$_brew_prefix/Cellar/neovim/${_nvim_version}/share/nvim/runtime"
  fi
  [[ -d "$_vimruntime_path" ]] && export VIMRUNTIME="$_vimruntime_path"
  unset _brew_prefix _nvim_version _vimruntime_path
fi

# Starship prompt (must be last)
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
