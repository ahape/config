#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Ubuntu Bootstrap..."

# 1. Update and install packages
echo "Updating apt repositories and installing packages..."
sudo apt-get update
sudo apt-get install -y zsh tmux screen neovim git curl software-properties-common build-essential

# Change default shell to zsh
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh) || echo "Failed to change shell. You may need to run 'chsh -s \$(which zsh)' manually."
fi

# 2. Setup Dotfiles
echo "Setting up dotfiles from common/..."
# Ensure we get the absolute path to the common directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/common" && pwd)"

# Helper function to create symlinks
link_file() {
    local src=$1
    local dest=$2
    
    # If the destination is already a symlink pointing to our source, skip
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Already linked: $dest"
        return
    fi

    # Backup existing file/directory or symlink
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi
    
    echo "Linking $src -> $dest"
    ln -s "$src" "$dest"
}

# Create necessary base directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.nuget/NuGet"

# Home Directory Dotfiles
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/screen/.screenrc" "$HOME/.screenrc"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_template" "$HOME/.gitignore_template"
link_file "$DOTFILES_DIR/editorconfig/.editorconfig" "$HOME/.editorconfig"

# .config Directory Applications
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/mgba" "$HOME/.config/mgba"

# NuGet Configuration
link_file "$DOTFILES_DIR/nuget/nuget.config" "$HOME/.nuget/NuGet/NuGet.Config"

echo "=========================================="
echo "Bootstrap complete!"
echo "Please restart your terminal or log out and log back in for shell changes (like Zsh) to take effect."
echo "=========================================="
