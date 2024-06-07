#!/bin/bash

# Define the directory where your Zsh dotfiles are stored
DOTFILES_ZSH_DIR=$(dirname "$(realpath "$0")")

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Zsh if not already installed
if ! command_exists zsh; then
  echo "Installing Zsh..."
  brew install zsh  # Adjust based on your package manager if not using Homebrew
else
  echo "Zsh is already installed."
fi

# Set Zsh as the default shell
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Changing the default shell to Zsh..."
  chsh -s /bin/zsh $USER
else
  echo "Default shell is already Zsh."
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

# Copy .zshrc
echo "Copying .zshrc from $DOTFILES_ZSH_DIR to $HOME..."
cp "$DOTFILES_ZSH_DIR/.zshrc" "$HOME/.zshrc"

# Copy .p10k.zsh
if [ -f "$DOTFILES_ZSH_DIR/.p10k.zsh" ]; then
  echo "Copying .p10k.zsh from $DOTFILES_ZSH_DIR to $HOME..."
  cp "$DOTFILES_ZSH_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
else
  echo ".p10k.zsh not found in $DOTFILES_ZSH_DIR. Skipping copy."
fi

# Copy zsh_history
echo "Copying zsh_history from $DOTFILES_ZSH_DIR to $HOME..."
cp "$DOTFILES_ZSH_DIR/.zsh_history" "$HOME/.zsh_history"

# Install Powerlevel10k theme if not already installed
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "Powerlevel10k theme is already installed."
fi

# Install Zsh plugins
echo "Installing Zsh plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"
plugins=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-completions"
  "zsh-users/zsh-syntax-highlighting"
)

for plugin in "${plugins[@]}"; do
  plugin_dir=$(basename "$plugin")
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_dir" ]; then
    echo "Installing $plugin_dir..."
    git clone "https://github.com/$plugin" "$ZSH_CUSTOM/plugins/$plugin_dir"
  else
    echo "$plugin_dir is already installed."
  fi
done

# Fix the .zshrc file (if necessary)
# Adjust this section based on your specific requirements
# For example, remove or customize according to your setup
# sed -i '' 's/${XDG_CACHE_HOME:-$HOME\/.cache}\/p10k-instant-prompt-${(%):-%n}.zsh/${XDG_CACHE_HOME:-$HOME\/.cache}\/p10k-instant-prompt-${(%):-%n}.zsh/g' "$HOME/.zshrc"

# Print instructions for sourcing .zshrc
echo "Zsh setup complete!"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
echo "If you have a custom .p10k.zsh configuration, make sure to review it in $HOME/.p10k.zsh."
echo "If you encounter issues, check the Zsh setup and ensure you have the necessary plugins and themes installed."
