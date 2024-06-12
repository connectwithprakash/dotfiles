#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to uninstall Oh My Zsh
uninstall_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Uninstalling Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    echo "Oh My Zsh has been uninstalled."
  else
    echo "Oh My Zsh is not installed."
  fi

  if [ -f "$HOME/.zshrc" ]; then
    echo "Removing .zshrc..."
    rm -f "$HOME/.zshrc"
  fi
  
  if [ -f "$HOME/.p10k.zsh" ]; then
    echo "Removing .p10k.zsh..."
    rm -f "$HOME/.p10k.zsh"
  fi
}

# Function to uninstall Zsh
uninstall_zsh() {
  if command_exists zsh; then
    echo "Uninstalling Zsh..."
    if command_exists brew; then
      brew uninstall zsh
    elif command_exists apt-get; then
      sudo apt-get remove --purge -y zsh
    else
      echo "Package manager not supported. Please uninstall Zsh manually."
      exit 1
    fi
    echo "Zsh has been uninstalled."
  else
    echo "Zsh is not installed."
  fi
}

# Function to change default shell back to Bash
change_default_shell() {
  if [ "$SHELL" != "/bin/bash" ]; then
    echo "Changing the default shell back to Bash..."
    chsh -s /bin/bash "$USER"
  else
    echo "Default shell is already Bash."
  fi
}

# Function to remove Zsh-related files and directories
remove_zsh_files() {
  echo "Removing Zsh-related files and directories..."
  rm -rf "$HOME/.zsh_history"
  rm -rf "$HOME/.zshenv"
  rm -rf "$HOME/.zlogin"
  rm -rf "$HOME/.zlogout"
  rm -rf "$HOME/.zsh"
  rm -rf "$HOME/.zshrc.d"
  rm -rf "$HOME/.cache"
}

# Function to remove Zsh plugins and themes directories
remove_plugins_and_themes() {
  echo "Removing Zsh plugins and themes directories..."
  rm -rf "$HOME/.oh-my-zsh/custom/plugins"
  rm -rf "$HOME/.oh-my-zsh/custom/themes"
  rm -rf "$HOME/.oh-my-zsh/custom"
}

# Main function to execute all steps
main() {
  uninstall_oh_my_zsh
  uninstall_zsh
  change_default_shell
  remove_zsh_files
  remove_plugins_and_themes

  echo "Uninstallation complete. Please restart your terminal or open a new terminal window."
}

# Run the main function
main
