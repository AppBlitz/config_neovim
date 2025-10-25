#!/bin/zsh

# ===============================================================
# Script to setup a development environment on Arch Linux
# Installs dependencies: Git, Node.js, Python, Go, Rust, Neovim, etc.
# Clones and sets up Neovim configuration from GitHub.
# Author: Your Name
# ===============================================================

set -e  # Exit immediately if a command fails
sudo -v  # Ask for sudo upfront

show_details="No"  # Set to "Yes" to show detailed command output

# ===============================================================
# Function to run commands with optional output suppression
# ===============================================================
run_command() {
  if [[ "$show_details" == "No" ]]; then
    "$@" &>/dev/null
  else
    "$@"
  fi
}

# ===============================================================
# Function to detect if the system is Arch Linux
# Returns 0 (success) if Arch Linux, 1 (failure) otherwise
# ===============================================================
is_arch() {
  if [ -f /etc/arch-release ]; then
    return 0
  else
    return 1
  fi
}

# ===============================================================
# Function to install dependencies for Arch Linux
# ===============================================================
install_dependencies() {
  if is_arch; then

    run_command sudo pacman -Syu --noconfirm

    run_command sudo pacman -S --needed --noconfirm \
      base-devel curl git nodejs npm unzip go luarocks \
      python lazygit neovim rustup

   
    export PATH="$HOME/.cargo/bin:$PATH"  # Ensure Rust tools are in PATH
    run_command rustup default stable
    run_command rustup component add rust-analyzer
    run_command cargo install --locked tree-sitter-cli

    echo "[INFO] Dependencies installation complete!"
  else
    echo "Error: Unsupported distribution. This script only works on Arch Linux."
    exit 1
  fi
}

# ===============================================================
# Function to clone Neovim configuration from GitHub
# Copies only the config_nvim folder to ~/.config/nvim
# ===============================================================
clonation_configuration() {
  run_command git clone --depth 1 https://github.com/AppBlitz/config_neovim /tmp/config_neovim


  run_command mkdir -p ~/.config
  run_command cp -r /tmp/config_neovim/config_nvim ~/.config/nvim

  run_command rm -rf /tmp/config_neovim
}

# ===============================================================
# Main execution
# ===============================================================
install_dependencies
clonation_configuration

echo "[SUCCESS] Development environment setup completed!"
