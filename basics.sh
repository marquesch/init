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

# --- Pre-flight Checks ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo. Please run: sudo ./install_apps.sh"
    fi
}

check_ubuntu() {
    if ! grep -qi "ubuntu" /etc/os-release; then
        log_error "This script is designed for Ubuntu only. Exiting."
    fi
}


install_common_dependencies() {
    log_info "Installing common system dependencies..."
    sudo apt update || log_error "Failed to update apt."
    sudo apt install -y curl wget gnupg apt-transport-https ca-certificates lsb-release software-properties-common || log_error "Failed to install common dependencies."
    log_success "Common dependencies installed."
}

install_common_utility() {
    log_info "Installing common utilities..."
    sudo apt install -y ffmpeg htop neofetch neovim net-tools sublime-text vim
}

install_spotify() {
    log_info "Installing Spotify via Snap..."
    if snap install spotify; then
        log_success "Spotify installed successfully."
    else
        log_error "Failed to install Spotify via Snap. Check your Snap installation or internet connection."
    fi
}

install_postman() {
    log_info "Installing Postman via Brew..."
    if brew install --cask postman; then
        log_success "Postman installed successfully."
    else
        log_error "Failed to install Postman via Brew. Check your Brew installation or internet connection."
    fi
}

install_brave_browser() {
    log_info "Installing Brave Browser..."
    if command -v brave-browser &> /dev/null; then
        log_info "Brave Browser is already installed. Skipping."
        return 0
    fi

    log_info "Adding Brave GPG key..."
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg || log_error "Failed to add Brave GPG key."

    log_info "Adding Brave APT repository..."
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null || log_error "Failed to add Brave APT repository."

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

    log_info "Adding Google Chrome GPG key..."
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg || log_error "Failed to add Google Chrome GPG key."

    log_info "Adding Google Chrome APT repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null || log_error "Failed to add Google Chrome APT repository."

    log_info "Updating apt cache and installing Google Chrome..."
    sudo apt update || log_error "Failed to update apt after adding Chrome repo."
    sudo apt install -y google-chrome-stable || log_error "Failed to install Google Chrome."
    log_success "Google Chrome installed successfully."
}

install_vscode() {
    log_info "Installing Visual Studio Code..."
    if command -v code &> /dev/null; then
        log_info "Visual Studio Code is already installed. Skipping."
        return 0
    fi

    log_info "Adding Microsoft GPG key..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg || log_error "Failed to add Microsoft GPG key."
    rm packages.microsoft.gpg

    log_info "Adding VS Code APT repository..."
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null || log_error "Failed to add VS Code APT repository."

    log_info "Updating apt cache and installing VS Code..."
    sudo apt update || log_error "Failed to update apt after adding VS Code repo."
    sudo apt install -y code || log_error "Failed to install Visual Studio Code."
    log_success "Visual Studio Code installed successfully."
}

install_flameshot() {
    log_info "Installing Flameshot..."
    if command -v flameshot &> /dev/null; then
        log_info "Flameshot is already installed. Skipping."
    else
        sudo apt install -y flameshot || log_error "Failed to install Flameshot."
        log_success "Flameshot installed successfully."
    fi

    log_info "Configuring Print Screen key for Flameshot (GNOME only)..."
    if command -v gsettings &> /dev/null && [ -n "$DESKTOP_SESSION" ] && [[ "$DESKTOP_SESSION" == *"gnome"* ]]; then
        # Disable default print screen behavior
        gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '[]'
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

        # Set custom command for Print Screen
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0 name 'Flameshot'
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0 command 'flameshot gui'
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0 binding 'Print'

        log_success "Flameshot configured to Print Screen key."
        log_warning "You might need to log out and log back in for the Flameshot keybinding change to take full effect."
    else
        log_warning "gsettings not found or not running GNOME desktop. Skipping Flameshot keybinding configuration. Please configure it manually in your system settings."
    fi
}

install_slack() {
    log_info "Installing Slack via Snap (classic confinement)..."
    if snap install slack --classic; then
        log_success "Slack installed successfully."
    else
        log_error "Failed to install Slack via Snap. Check your Snap installation or internet connection."
    fi
}

# --- Script Execution ---
set -e # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp at the beginning

check_root
check_ubuntu

log_info "Starting application installation script for Ubuntu."

install_common_dependencies
install_spotify
install_postman
install_brave_browser
install_chrome_browser
install_vscode
install_flameshot
install_slack

log_success "All requested applications have been installed (or skipped if already present)."
log_info "Remember to log out and log back in, or reboot your system, for all changes (especially Flameshot keybinding) to take full effect."
