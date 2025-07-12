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

# --- Script Start ---
set -e # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp

log_info "Starting WezTerm and font installation script."

# --- Install WezTerm ---
log_info "Attempting to install WezTerm..."

if command -v wezterm &> /dev/null; then
    log_info "WezTerm is already installed. Skipping installation."
else
    log_info "Setting up WezTerm APT repository..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg || log_error "Failed to add WezTerm GPG key."
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list > /dev/null || log_error "Failed to add WezTerm APT repository."
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg || log_error "Failed to set permissions on WezTerm GPG key."

    log_info "Updating apt package index..."
    sudo apt update || log_error "Failed to update apt after adding WezTerm repo."

    log_info "Installing WezTerm..."
    sudo apt install -y wezterm || log_error "Failed to install WezTerm."
    log_success "WezTerm installed."
fi

# --- Install Meslo Nerd Font ---
log_info "Attempting to install Meslo Nerd Font..."
brew install --cask font-meslo-lg-nerd-font

# --- Copy background image file ---
mkdir -p ~/.config/wezterm
cp bg.jpg ~/.config/wezterm/bg.jpg

# --- Set WezTerm as default terminal for GNOME ---
log_info "Attempting to set WezTerm as the default terminal (GNOME only)..."
if command -v gsettings &> /dev/null && [ -n "$DESKTOP_SESSION" ] && [[ "$DESKTOP_SESSION" == *"gnome"* ]]; then
    if gsettings set org.gnome.desktop.default-applications.terminal exec "/usr/bin/wezterm"; then
        log_success "WezTerm set as default GNOME terminal."
    else
        log_warning "Failed to set WezTerm as default terminal. This might happen if you're not in a GNOME environment or permissions are incorrect."
    fi
else
    log_info "gsettings not available or not running a GNOME desktop. Skipping setting default terminal."
fi

log_success "WezTerm installation and configuration complete!"
log_warning "You may need to restart your terminal or session for changes (especially default terminal) to take full effect."
