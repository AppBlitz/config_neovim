#!/bin/zsh

set -e
sudo -v
show_details="No"

# Function for install dependencies
install_dependencies() {
  if is_arch; then
    run_command sudo pacman -Syu --noconfirm
    run_command sudo pacman -S --needed --noconfirm base-devel curl git nodejs npm unzip go luarocks
    run_command sudo pacman -S --needed --noconfirm python lazygit neovim
    run_command sudo pacman -S --needed --noconfirm rustup
    run_command rustup default stable
    run_command rustup component add rust-analyzer
    run_command export PATH="$HOME/.cargo/bin:$PATH"
    run_command cargo install --locked tree-sitter-cli
  else
    echo "Error no search distribution"
  fi
}

# Function for run commands
run_command() {
  if [[ "$show_details" == "No" ]]; then
    "$@" &>/dev/null
  else
    "$@"
  fi
}
# Function verification if system operative is arch linux
is_arch() {
  if [ -f /etc/arch-release ]; then
    return 0
  else
    return 1
  fi
}
clonation_configuration() {
  run_command git clone --depth 1 https://github.com/AppBlitz/config_neovim /tmp/config_neovim
  run_command mkdir -p ~/.config
  run_command cp -r /tmp/config_neovim/config_nvim ~/.config/nvim
  run_command rm -rf /tmp/config_neovim
}

install_dependencies
clonation_configuration
