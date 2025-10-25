#!/bin/zsh

# Exit immediately if any command fails
set -e

# Keep sudo alive until script finishes
sudo -v

# Toggle command output: "No" = silent, "Yes" = verbose
show_details="No"

# -------------------------------
# Helper function to run commands
# -------------------------------
run_command() {
  if [[ "$show_details" == "No" ]]; then
    "$@" &>/dev/null
  else
    "$@"
  fi
}

# ----------------------------------------
# Check if the operating system is Arch Linux
# ----------------------------------------
is_arch() {
  [ -f /etc/arch-release ]
}

# ----------------------------------------
# Install system dependencies
# ----------------------------------------
install_dependencies() {
  if is_arch; then
    run_command sudo pacman -Syu --noconfirm
    run_command sudo pacman -S --needed --noconfirm \
      base-devel curl git nodejs npm unzip go luarocks python lazygit neovim rustup
    # Setup Rust only if not installed
    if ! command -v rustc &>/dev/null; then
      run_command rustup default stable
      run_command rustup component add rust-analyzer
    fi

    # Update PATH for cargo binaries
    export PATH="$HOME/.cargo/bin:$PATH"

    # Install tree-sitter CLI only if it's missing
    if ! command -v tree-sitter &>/dev/null; then
      echo "🔧 Installing tree-sitter-cli..."
      run_command cargo install --locked tree-sitter-cli
    fi
  else
    echo "Unsupported distribution. Exiting."
    exit 1
  fi
}

# ----------------------------------------
# Setup Neovim configuration
# ----------------------------------------
setup_neovim_config() {
  local local_config="$HOME/mis-configs/config_nvim"

  # Use local configuration if available, otherwise clone from GitHub
  if [ -d "$local_config" ]; then
    run_command mkdir -p ~/.config
    run_command cp -r "$local_config" ~/.config/nvim
  else
    run_command git clone --depth 1 https://github.com/AppBlitz/config_neovim /tmp/config_neovim
    run_command mkdir -p ~/.config
    run_command cp -r /tmp/config_neovim/config_nvim ~/.config/nvim
    run_command rm -rf /tmp/config_neovim
  fi
}

# -------------------------------
# Main script execution
# -------------------------------
install_dependencies
setup_neovim_config

echo "Installation complete! Neovim and dependencies are ready."
