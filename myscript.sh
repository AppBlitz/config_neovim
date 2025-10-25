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
      run_command cargo install --locked tree-sitter-cli
    fi
  else
    echo "Unsupported distribution. Exiting."
    exit 1
  fi
}

# ----------------------------------------
# Function to find local Neovim configuration
# ----------------------------------------
find_config_dir() {
  local dir_name="$1"
  local search_paths=(
    "$HOME/mis-configs"
    "$HOME/repos"
    "/tmp"
  )

  # Search in predefined paths
  for path in "${search_paths[@]}"; do
    if [ -d "$path/$dir_name" ]; then
      echo "$path/$dir_name"
      return 0
    fi
  done

  # If not found, search recursively in $HOME
  local result
  result=$(find "$HOME" -type d -name "$dir_name" 2>/dev/null | head -n 1)

  if [ -n "$result" ]; then
    echo "$result"
    return 0
  fi

  # If still not found, return failure
  return 1
}

# ----------------------------------------
# Setup Neovim configuration
# ----------------------------------------
setup_neovim_config() {
  local config_path

  # Try to find local configuration
  config_path=$(find_config_dir "config_nvim") || {
    # Fallback to GitHub if not found
    run_command git clone --depth 1 https://github.com/AppBlitz/config_neovim /tmp/config_neovim
    config_path="/tmp/config_neovim/config_nvim"
  }

  # Create Neovim config directory and copy configuration
  run_command mkdir -p ~/.config
  run_command cp -r "$config_path" ~/.config/nvim

  # Remove temporary clone if used
  if [[ "$config_path" == "/tmp/config_neovim/config_nvim" ]]; then
    run_command rm -rf /tmp/config_neovim
  fi
}

# -------------------------------
# Main script execution
# -------------------------------
install_dependencies
setup_neovim_config

echo "Installation complete! Neovim and dependencies are ready."

