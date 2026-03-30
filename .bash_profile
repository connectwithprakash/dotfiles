# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don't want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done

# Add tab completion for many Bash commands
if command -v brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# Add path for homebrew (detect architecture)
if [ -f /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi

# Set VIMRUNTIME dynamically if nvim is available
if command -v nvim &> /dev/null; then
	_brew_prefix="$(brew --prefix 2>/dev/null || echo "")"
	_vimruntime_path="$_brew_prefix/share/nvim/runtime"
	if [ ! -d "$_vimruntime_path" ] && [ -n "$_brew_prefix" ]; then
		# Fallback to version-specific Cellar path
		_nvim_version=$(nvim --version 2>/dev/null | head -n 1 | awk '{print $2}' | sed 's/^v//')
		_vimruntime_path="$_brew_prefix/Cellar/neovim/${_nvim_version}/share/nvim/runtime"
	fi
	if [ -d "$_vimruntime_path" ]; then
		export VIMRUNTIME="$_vimruntime_path"
	fi
	unset _brew_prefix _nvim_version _vimruntime_path
fi
