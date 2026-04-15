#!/bin/bash

set -euo pipefail

echo "Starting Ubuntu Bootstrap..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/common"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Could not find dotfiles directory: $DOTFILES_DIR" >&2
    exit 1
fi

next_backup_path() {
    local dest=$1
    local backup="${dest}.backup"
    local index=1

    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="${dest}.backup.${index}"
        index=$((index + 1))
    done

    printf '%s\n' "$backup"
}

link_file() {
    local src=$1
    local dest=$2
    local existing_target
    local backup

    if [ ! -e "$src" ]; then
        echo "Source does not exist: $src" >&2
        exit 1
    fi

    if [ -L "$dest" ]; then
        existing_target="$(readlink -f "$dest" || true)"
        if [ "$existing_target" = "$src" ]; then
            echo "Already linked: $dest"
            return
        fi
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup="$(next_backup_path "$dest")"
        echo "Backing up existing $dest to $backup"
        mv "$dest" "$backup"
    fi

    echo "Linking $src -> $dest"
    ln -s "$src" "$dest"
}

link_directory_contents() {
    local src_dir=$1
    local dest_dir=$2
    local entry

    if [ ! -d "$src_dir" ]; then
        return
    fi

    mkdir -p "$dest_dir"

    shopt -s nullglob
    for entry in "$src_dir"/*; do
        link_file "$entry" "$dest_dir/$(basename "$entry")"
    done
    shopt -u nullglob
}

filter_available_packages() {
    local available_packages=()
    local missing_packages=()
    local package

    for package in "$@"; do
        if apt-cache show "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            missing_packages+=("$package")
        fi
    done

    FILTERED_PACKAGES=("${available_packages[@]}")
    MISSING_PACKAGES=("${missing_packages[@]}")
}

install_nvm() {
    local nvm_dir="$HOME/.nvm"
    local nvm_script="$nvm_dir/nvm.sh"
    local nvm_version="v25.8.2"

    if [ ! -s "$nvm_script" ]; then
        echo "Installing nvm $nvm_version..."
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh" | bash
    else
        echo "nvm already installed; skipping download."
    fi

    if [ -s "$nvm_script" ]; then
        export NVM_DIR="$nvm_dir"
        # shellcheck source=/dev/null
        . "$nvm_script"
    else
        echo "nvm installation failed; $nvm_script not found." >&2
        exit 1
    fi
}

install_latest_node_with_nvm() {
    if ! command -v nvm >/dev/null 2>&1; then
        echo "nvm command not found. Did install_nvm run?" >&2
        exit 1
    fi

    echo "Installing latest Node.js release via nvm..."
    if nvm ls node >/dev/null 2>&1; then
        nvm install node --reinstall-packages-from=node
    else
        nvm install node
    fi
    nvm alias default node
    nvm use node >/dev/null
    echo "Active Node.js version: $(node --version)"
}

echo "Updating apt repositories and installing packages..."
sudo apt-get update

core_packages=(
    build-essential
    curl
    git
    neovim
    screen
    software-properties-common
    tmux
    zsh
)

extra_packages=(
    bat
    fd-find
    fzf
    jq
    python3
    python3-pip
    ripgrep
    universal-ctags
    unzip
    wget
    yq
    eza
)

filter_available_packages "${core_packages[@]}"
sudo apt-get install -y "${FILTERED_PACKAGES[@]}"

filter_available_packages "${extra_packages[@]}"
if [ "${#FILTERED_PACKAGES[@]}" -gt 0 ]; then
    echo "Installing additional CLI packages..."
    sudo apt-get install -y "${FILTERED_PACKAGES[@]}"
fi

if [ "${#MISSING_PACKAGES[@]}" -gt 0 ]; then
    echo "Skipping packages not available from the current apt sources: ${MISSING_PACKAGES[*]}"
fi

install_nvm
install_latest_node_with_nvm

zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$current_shell" != "$zsh_path" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$zsh_path" || echo "Failed to change shell. You may need to run 'chsh -s $zsh_path' manually."
fi

echo "Setting up dotfiles from common/..."

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/nvim/site"
mkdir -p "$HOME/.nuget/NuGet"

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/screen/.screenrc" "$HOME/.screenrc"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_common" "$HOME/.gitignore_common"
link_file "$DOTFILES_DIR/git/.gitignore_csharp" "$HOME/.gitignore_csharp"
link_file "$DOTFILES_DIR/git/.gitignore_nodejs" "$HOME/.gitignore_nodejs"
link_file "$DOTFILES_DIR/git/.gitignore_python" "$HOME/.gitignore_python"
link_file "$DOTFILES_DIR/git/.gitignore_agentic" "$HOME/.gitignore_agentic"
link_file "$DOTFILES_DIR/editorconfig/.editorconfig" "$HOME/.editorconfig"

link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_directory_contents "$DOTFILES_DIR/nvim/ftdetect" "$HOME/.local/share/nvim/site/ftdetect"
link_directory_contents "$DOTFILES_DIR/nvim/syntax" "$HOME/.local/share/nvim/site/syntax"
link_file "$DOTFILES_DIR/mgba" "$HOME/.config/mgba"

link_file "$DOTFILES_DIR/nuget/nuget.config" "$HOME/.nuget/NuGet/NuGet.Config"

echo "=========================================="
echo "Bootstrap complete!"
echo "Please restart your terminal or log out and log back in for shell changes (like Zsh) to take effect."
echo "=========================================="
