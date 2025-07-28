#!/bin/bash

# --- Helper Functions for Logging ---
log_info() {
    echo -e "\n\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\n\033[0;32m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\n\033[0;33m[WARNING]\033[0m $1"
}

log_error() {
    echo -e "\n\033[0;31m[ERROR]\033[0m $1" >&2
    exit 1
}

install_common_utility() {
    log_info "Installing common utilities..."
    sudo apt install -y flameshot ffmpeg htop neofetch net-tools vim 
}

install_fzf() {
    log_info "Installing fzf..."
    if command -v fzf; then
        log_info "fzf already installed. Skipping..."
        return 0
    fi
    git clone git@github.com:junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all
}

install_asdf() {
    if command -v asdf; then
        log_info "asdf already installed. Skipping..."
        return 0
    fi

    log_info "Starting asdf install using git + bash..."
    file_name=asdf-v0.18.0-linux-amd64.tar.gz
    wget "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/$file_name"
    tar -xzf "$file_name" -C "$HOME/.local/bin"
    log_success "Installed asdf successfully!"
    log_info "Cleaning up"
    rm -f $file_name
}

install_brave_browser() {
    log_info "Installing Brave Browser..."
    if command -v brave-browser &> /dev/null; then
        log_info "Brave Browser is already installed. Skipping."
        return 0
    fi
 
    log_info "Adding Brave GPG key..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    log_info "Adding Brave APT repository..."
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

    log_info "Updating apt cache and installing Brave Browser..."
    sudo apt update || log_error "Failed to update apt after adding Brave repo."

    sudo apt install -y brave-browser || log_error "Failed to install Brave Browser."
    log_success "Brave Browser installed successfully."
}

install_chrome_browser() {
    log_info "Installing Google Chrome Browser..."
    if command -v google-chrome &> /dev/null; then
        log_info "Google Chrome is already installed. Skipping."
        return 0
    fi

    log_info "Downloading Google Chrome Browser .deb package..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb || log_error "Failed to install Google Chrome."
    log_success "Google Chrome installed successfully."

    log_info "Cleaning up..."
    rm google-chrome-stable_current_amd64.deb
    log_info "Done cleaning up..."
}

install_vscode() {
    log_info "Installing Visual Studio Code..."
    if command -v code &> /dev/null; then
        log_info "Visual Studio Code is already installed. Skipping."
        return 0
    fi
    
    log_info "Downloading Visual Studio Code .deb package..."
    # TODO get vscode version dinamically
    file_name=code_1.102.0-1752099874_amd64.deb
    wget "https://vscode.download.prss.microsoft.com/dbazure/download/stable/cb0c47c0cfaad0757385834bd89d410c78a856c0/$file_name"

    log_info "Installing Visual Studio Code via apt..."
    sudo apt install -y "./$file_name"
    log_success "Visual Studio Code installed successfully."

    log_info "Cleaning up..."
    rm -f "$file_name"
    log_info "Done cleaning up..."
}

install_go() {
    log_info "Installing Go..."

    if command -v go; then
        log_info "Go already installed. Skipping..."
        return 0
    fi

    sudo mkdir -p /usr/local
    wget https://go.dev/dl/go1.24.5.linux-amd64.tar.gz -O "${HOME}/Downloads/go.tar.gz"
    sudo tar -xzf "${HOME}/Downloads/go.tar.gz" -C /usr/local
    rm "${HOME}/Downloads/go.tar.gz"

    log_success "Go installed successfully!"
}

install_neovim() {
    log_info "Installing Neovim..."

    if command -v nvim; then
        log_info "Neovim already installed. Skipping..."
        return 0
    fi

    wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz
    tar --strip-components=1 -xzf nvim-linux-x86_64.tar.gz -C "${HOME}/.local"
    rm nvim-linux-x86_64.tar.gz

    log_success "Neovim successfully installed!"
}

install_rust() {
    log_info "Installing rust..."

    if command -v rust; then
        log_info "Rust already installed. Skipping..."
        return 0
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    log_success "Rust and cargo successfully installed!"
}

install_spotify_player() {
    log_info "Installing spotify_player..."

    if command -v spotify_player; then
        log_info "spotify_player already installed. Skipping..."
        return 0
    fi

    cargo install spotify_player --locked
    log_success "spotify_player installed successfully!"
}

install gopls() {
    log_info "Installing gopls..."

    if command -v gopls; then
        log_info "gopls already installed. Skipping..."
        return 0
    fi

    go install golang.org/x/tools/gopls@latest

    log_success "gopls installed successfully..."
}

# --- Script Execution ---
set -e # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp at the beginning

log_info "Starting application installation script for Ubuntu."

mkdir -p "$HOME/.local/bin"

install_common_utility
install_asdf
install_fzf
install_brave_browser
install_chrome_browser
install_vscode
install_go
install_gopls
install_neovim
install_rust
install_spotify_player

log_success "All requested applications have been installed (or skipped if already present)."
log_info "Remember to log out and log back in, or reboot your system, for all changes (especially Flameshot keybinding) to take full effect."

