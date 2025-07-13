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
    sudo apt install -y flameshot ffmpeg htop neofetch neovim net-tools vim 
}

install_fzf() {
    log_info "Installing fzf..."
    if command -v fzf; then
        log_info "fzf already installed. Skipping..."
        return 0
    fi
    file_name=fzf-0.64.0-linux_amd64.tar.gz
    wget "https://github.com/junegunn/fzf/releases/download/v0.64.0/$file_name"
    tar -xzf "$file_name" -C "$HOME/.local/bin"
    rm -f "$file_name"
}

install_asdf() {
    if command -v asdf; then
        log_info "asdf already installed. Skipping..."
        return 0
    fi

    log_info "Starting asdf install using git + bash..."
    file_name=asdf-v0.18.0-darwin-amd64.tar.gz
    wget "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/$file_name"
    tar -xzf "$file_name" -C "$HOME/.local/bin"
    log_success "Installed asdf successfully!"
    log_info "Cleaning up"
    rm -f $file_name
}

install_spotify() {
    log_info "Installing Spotify using Snap..."

    if command -v spotify; then
        log_info "Spotify already installed. Skipping..."
        return 0
    elif snap install spotify; then
        log_success "Spotify installed successfully."
    else
        log_error "Failed to install Spotify via Snap."
    fi
}

install_postman() {
    log_info "Installing Postman via Snap..."
    if command -v postman; then
        log_info "Postman already installed. Skipping..."
    elif snap install postman; then
        log_success "Postman installed successfully."
    else
        log_error "Failed to install Postman via Snap. Check your Snap installation or internet connection."
    fi
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

install_slack() {
    log_info "Installing Slack via Snap (classic confinement)..."
    if command -v snap; then
        log_info "Snap already installed. Skipping..."
        return 0
    elif snap install slack --classic; then
        log_success "Slack installed successfully."
    else
        log_error "Failed to install Slack via Snap. Check your Snap installation or internet connection."
    fi
}

# --- Script Execution ---
set -e # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp at the beginning

log_info "Starting application installation script for Ubuntu."

mkdir -p "$HOME/.local/bin"

install_common_utility
install_asdf
install_fzf
install_spotify
install_postman
install_brave_browser
install_chrome_browser
install_vscode
install_slack

log_success "All requested applications have been installed (or skipped if already present)."
log_info "Remember to log out and log back in, or reboot your system, for all changes (especially Flameshot keybinding) to take full effect."
